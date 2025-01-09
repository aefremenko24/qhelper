#  QHelper

MacOS application for parsing Northeastern University Lighting Cues Sheets (in XLSX format) and adding time stamps for all groups to a given QLab workspace as cues of a selected type. Allows for customization of grouping to fit the work style of the lighting engineer. 

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

* This project requires a MacOS version 10.13 or later.
* To debug and test this project, XCode IDE version 16.0 or later should be used.
* The latest version of the Command Line Developer Tools must be installed on the Mac running the project.  
* Make sure QLab is installed on the machine running QHelper and a workspace is open.

### Building and running QHelper

Once the project is cloned and all prerequisites are satisfied, go to the **Product** tab in XCode and press **Run** to build and run the project. 

### Permissions

QHelper will require some user permission to function properly:
* **Network: Incoming Connections (Server)** - Receive responses from QLab (primarily used to get unique cue IDs).
* **Network: Outgoing Connections (Client)** - Send messages to QLab. Used for adding cues, specifying their parameters, and arranging cue groups.
* **File Access: User Selected File (Read Only)** - Parse XLSX files added by the user.
* **Resourse Access: Apple Events** - Run Apple Scripts to convert generic MIDI cues into GIO commands. 

## Built With

* [CoreXLSX](https://github.com/CoreOffice/CoreXLSX) - Excel spreadsheet (XLSX) format parser.
* [OSCKit](https://tldp.org/HOWTO/NCURSES-Programming-HOWTO/) - Open Sound Control (OSC) library.

## Authors

* **Arthur Efremenko** - *Initial work* - [GitHub](https://github.com/aefremenko24)
