from enum import StrEnum

class CueType(StrEnum):
    AUDIO = "audio"
    MIC = "mic"
    VIDEO = "video"
    CAMERA = "camera"
    FADE = "fade"
    OSC = "osc"
    MIDI = "midi"
    MIDI_FILE = "midi file"
    TIMECODE = "timecode"
    GROUP = "group"
    START = "start"
    STOP = "stop"
    PAUSE = "pause"
    LOAD = "load"
    RESET = "reset"
    DEVAMP = "devamp"
    GOTO = "goto"
    TARGET = "target"
    ARM = "arm"
    DISARM = "disarm"
    WAIT = "wait"
    MEMO = "memo"
    SCRIPT = "script"
    CUELIST = "cuelist"
    CUE_LIST = "cue list"

CONNECTION_SUCCESS_MESSAGE = "You are connected to QLab. Host: {host}, Port: {port}"
CONNECTION_FAILURE_MESSAGE = "Failed to connect to the server using port {port}."
WRITE_ERROR_MESSAGE = "Failed to communicate with QLab. The command {command} WAS NOT sent."
READ_ERROR_MESSAGE = "Failed to receive the response from QLab. The previous command might not have been recorded."
CONNECTION_NOT_ESTABLISHED_WARNING = "This method should not be called before the connection to QLab is established."

EXIT_SUCCESS_MESSAGE = "Program run finished successfully. Your cues were written to your QLab workspace."
EXIT_FAILURE_MESSAGE = ("Something went wrong during the execution of the program. "
                        "Your cues might have been written to the QLab workspace partially.")

WORKSPACE_NAME_PROMPT = "Please enter the name of the QLab workspace you would like to write cues to: "
INVALID_WORKSPACE_NAME_PROMPT = "The workspace name must not be empty. Try again: "

# Default host used to connect to QLab workspaces
DEFAULT_HOST = "localhost"

# The default port QLab listens for incoming OSC on.
# Should be used for all commands sent through TCP and UDP by default.
DEFAULT_PORT = 53000

# The UDP port on which QLab listens to plain text and attempts to interpret it as OSC.
# Should be used as a back-up, when the default port connection fails.
PLAIN_TEXT_PORT = 53535

# Maximum number of seconds the client will wait for a response from QLab.
MAX_RESPONSE_TIME = 2.0

# Maximum number of tries to send/receive a request/response
MAX_NUM_TRIES = 3

# These are QLab application methods used to communicate with workspaces.
CONNECT_TO_WORKSPACE = "/workspace/{id}/connect {passcode_string}"
DISCONNECT_FROM_WORKSPACE = "/workspace/{id}/disconnect"
SAVE_TO_DISK = "/workspace/{id}/save"
CREATE_CUE = "/workspace/{id}/new {cue_type}"
SET_CUE_NAME = "/cue/{number}/name {string}"
SET_CUE_PREWAIT = "/cue/{number}/preWait {time_stamp}"