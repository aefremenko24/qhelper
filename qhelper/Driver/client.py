import asyncio
import json
from dataclasses import dataclass
from typing import Any, Optional
from pythonosc import udp_client
from utils import *

@dataclass
class Client():

    client: udp_client.SimpleUDPClient = None

    def start_client(self):
        """
        Initializes a UDC connection to the server using the DEFAULT_HOST and DEFAULT_PORT
        and sets self.client to SimpleUDPCClient for the opened connection.
        If the connection cannot be established, tries to initialize a UDP connection using PLAIN_TEXT_LISTENING_PORT.
        If both connection attempts are unsuccessful, throws a ConnectionError.

        :mutates: self.client to store the client used for the current connection.
        :throws: ConnectionError if neither UDP connections to DEFAULT_PORT and PLAIN_TEXT_LISTENING_PORT can be established.
        """
        try:
            self.client = udp_client.SimpleUDPClient(DEFAULT_HOST, DEFAULT_LISTENING_PORT)
            return print(CONNECTION_SUCCESS_MESSAGE.format(host=DEFAULT_HOST, port=DEFAULT_LISTENING_PORT))
        except:
            print(CONNECTION_FAILURE_MESSAGE.format(port=DEFAULT_LISTENING_PORT))
            print("Trying the plain text port...")
        try:
            self.client = udp_client.SimpleUDPClient(DEFAULT_HOST, PLAIN_TEXT_LISTENING_PORT)
            return print(CONNECTION_SUCCESS_MESSAGE.format(host=DEFAULT_HOST, port=PLAIN_TEXT_LISTENING_PORT))
        except:
            print(CONNECTION_FAILURE_MESSAGE.format(port=PLAIN_TEXT_LISTENING_PORT))
            print("Will not attempt to establish a connection anymore.")
            raise ConnectionError

    def send_command(self, command: str, args: list = []) -> None:
        """
        Sends the given command to QLab for a maximum number of tries of MAX_NUM_TRIES.

        :param command: Command to send.
        :param args: Command arguments.
        :raises: UserWarning if this method is called before the connection to QLab is established.
        :raises: ConnectionError if the command cannot be sent after MAX_NUM_TRIES tries.
        """
        num_tries_left = MAX_NUM_TRIES

        if not self.client:
            raise UserWarning(CONNECTION_NOT_ESTABLISHED_WARNING)
        while num_tries_left:
            try:
                self.client.send_message(command, args)
                return
            except:
                num_tries_left -= 1

        raise ConnectionError(WRITE_ERROR_MESSAGE.format(command=command, args=args))

    def connect_to_workspace(self, workspace: str, passcode_string: str = "") -> None:
        """
        Establishes a connection to the QLab workspace.
        If the workspace has a passcode, you MUST supply it before any other commands will be accepted by the workspace.
        If the workspace does not have a passcode set, establish_connection() call is optional.

        :param workspace: The name of the QLab workspace.
        :param passcode_string: Optional passcode string for the workspace.
        :throws: UserWarning if the connection to QLab is not established.
        :throws: ConnectionError if failed to connect to the QLab workspace.
        """
        method_call = CONNECT_TO_WORKSPACE.format(id=workspace)
        args = [passcode_string]
        self.send_command(method_call, args)

    def disconnect_from_workspace(self, workspace: str) -> None:
        """
        Disconnect from the given workspace.
        Should be invoked when no more messages will be sent to the workspace.

        :param workspace: Name of the QLab workspace.
        :throws: UserWarning if the connection to QLab is not established.
        :throws: ConnectionError if failed to disconnect from the workspace.
        """
        method_call = DISCONNECT_FROM_WORKSPACE.format(id=workspace)
        self.send_command(method_call)

    def save_to_disk(self, workspace: str) -> None:
        """
        Tells the given workspace to save itself to disk.

        :param workspace: Name of the QLab workspace.
        :throws: UserWarning if the connection to QLab is not established.
        :throws: ConnectionError if failed to connect to the QLab workspace.
        """
        method_call = SAVE_TO_DISK.format(id=workspace)
        self.send_command(method_call)

    def create_cue(self, workspace: str, cue_type: CueType):
        """
        Creates a cue of a given type.

        :param workspace: Name of the QLab workspace.
        :param cue_type: Cue type (see CueType enum in utils.py).
        """
        method_call = CREATE_CUE.format(id=workspace)
        args = [cue_type]
        self.send_command(method_call, args)

    def set_cue_prewait(self, time_stamp: str) -> None:
        """
        Sets the pre-wait time for the currently selected cue.

        :param time_stamp: Time stamp of the cue pre-wait time in the format MM:SS.ms
        :throws: UserWarning if the connection to QLab is not established.
        :throws: ConnectionError if failed to connect to the QLab workspace.
        """
        method_call = SET_CUE_PREWAIT
        args = [time_stamp]
        self.send_command(method_call, args)

    def set_cue_name(self, name: str) -> None:
        """
        Sets the name for the currently selected cue.

        :param cue_number: Unique ID of the cue.
        :param name: Name of the cue as a string.
        """
        method_call = SET_CUE_NAME
        args = [name]
        self.send_command(method_call, args)

    def create_group(self, workspace: str, group_name: str) -> None:
        """
        Creates a cue group in the given workspace.

        :param workspace: Name of the QLab workspace.
        :param group_name: Name of the cue group.
        """
        self.create_cue(workspace, CueType.GROUP)
        self.set_cue_name(group_name)

    def create_midi_cue(self, workspace: str, pre_wait: str) -> None:
        """
        Creates a midi cue with the given pre-wait time in the given workspace.

        :param workspace: Name of the QLab workspace.
        :param pre_wait: Pre-wait time for the cue.
        """
        self.create_cue(workspace, CueType.MIDI)
        self.set_cue_prewait(pre_wait)

    def parse_cue_dict(self, cue_dict: dict, workspace: str) -> None:
        """
        Parses the dictionary containing QLab cue information and adds the cues to the given QLab workspace.
        For the dictionary to be parsed properly, the keys must represent group names
        and values must represent subgroups or cue pre-wait times.

        :param cue_dict: Dictionary containing QLab cue information.
        :param workspace: Name of the QLab workspace.
        :throws: ValueError if the dictionary provided is invalid.
        """
        for key, value in cue_dict.items():
            self.create_group(workspace, key)
            if isinstance(value, dict):
                self.parse_cue_dict(value, workspace)
            elif isinstance(value, list):
                for time_stamp in value:
                    self.create_midi_cue(workspace, time_stamp)

def serialize(message: Any) -> bytes:
    """
    Serializes the given message to a json string that can be sent over TCP/UDP.

    :param message: The message to serialize as a Python object (string, list, dict, etc).
    :return: The serialized message.
    """
    return json.dumps(message).encode("utf-8")

def deserialize(message: bytes) -> Any:
    """
    Deserializes the given message from a json string received over TCP/UDP into a Python object.

    :param message: The message to deserialize as bytes.
    :return: The deserialized message.
    :raises: ValueError If the message is invalid.
    """
    try:
        return json.loads(message)
    except ValueError:
        raise ValueError("Message is not valid JSON.")
