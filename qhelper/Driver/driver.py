#!/usr/local/bin/python3.11

from client import *
from utils import *
from parser import sanitize_filepath, extract_tables
import sys

def prompt_workspace_name() -> str:
    """
    Prompts the user to enter the name of the QLab workspace they would like to work with.

    :return: Name of the QLab workspace.
    """
    print(WORKSPACE_NAME_PROMPT)
    workspace_name = input()
    while not workspace_name:
        workspace_name = input(INVALID_WORKSPACE_NAME_PROMPT)
    return workspace_name

def prompt_workspace_passcode() -> str:
    """
    Prompts the user to enter the pass code for the QLab workspace.

    :return: Pass code for the QLab workspace.
    """
    print(WORKSPACE_PASSCODE_PROMPT)
    workspace_passcode = input()
    return workspace_passcode.strip()

def main(filepath: str) -> None:
    try:
        filepath = sanitize_filepath(filepath)
        cue_dict = extract_tables(filepath)
        workspace_name = prompt_workspace_name()
        workspace_passcode = prompt_workspace_passcode()
        client = Client()
        client.start_client()
        client.connect_to_workspace(workspace_name, workspace_passcode)
        client.parse_cue_dict(cue_dict, workspace_name)
        client.save_to_disk(workspace_name)
        client.disconnect_from_workspace()
        print(EXIT_SUCCESS_MESSAGE)
    except Exception as e:
        print(EXIT_FAILURE_MESSAGE)
        print(f"Error message: {e}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        raise Exception("Please provide an excel file path.")
    json.dump(main(sys.argv[1]), sys.stdout, indent=4)
