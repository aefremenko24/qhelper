import csv
import datetime
import json
import math
import os
import re
import sys
from audioop import reverse
from copy import deepcopy

from dateutil.parser import parse, ParserError

import pandas as pd

from typing import Tuple, List, Optional

#CUE_TIME_REGEX = r"^([0-5]?[0-9]):[0-5][0-9].?[0-9]?[0-9]?$"
CUE_TIME_FORMAT = "%M:%S"
CUE_TIME_FORMAT_MS = "%M:%S.%f"
CUE_TIME_FORMAT_HOURS = "%H:%M:%S"
CUE_TIME_FORMAT_HOURS_DECIMAl = "%H:%M.%f"
CUE_TIME_FORMAT_COLONS = "%H:%M:%S:%f"

CUE_TIME_LABELS = ["Cue Start Time", "QLAB TIMING", "Exact Time"]
EXAMPLE_LABELS = ["EXAMPLE FORM"]

EMPTY_TIME_CELL_TOLERANCE = 2

def find_first_cell_occurrences(csv_file: str, labels: List[str]) -> List[Tuple[int, int]]:
    """
    Finds the first occurrences of one of the given labels in the given csv file and returns their positions.
    :param labels: Labels to look for,
    :return: Positions of the first occurrences of one of the given labels.
    """
    found_time_cells = []
    for label in labels:
        found_time_cells = find_cell(csv_file, label)
        if found_time_cells:
            break
    return found_time_cells

def remove_example_tables(cue_time_positions: List[Tuple[int, int]], example_positions: List[Tuple[int, int]]):
    """
    Removes the example cue tables by cross-checking the rows and columns for the example label position and cue times position.

    :param cue_time_positions: Positions of all "Cue Start Time" cells.
    :param example_positions: Positions of all "EXAMPLE FORM" cells.
    :return: Filtered list of cue time positions.
    """
    final_cue_times = deepcopy(cue_time_positions)

    for example_position in example_positions:
        for cue_time_position_index, cue_time_position in enumerate(final_cue_times):
            if cue_time_position[0] > example_position[0]:
                final_cue_times.pop(cue_time_position_index)
                break

    return final_cue_times

def sanitize_cell(cell: str) -> Optional[str]:
    """
    Removes any extra characters from a cell, leaving only the time stamp if present.

    :param cell: String representing a cell to be sanitized.
    :return: Sanitized string or None if the string is an invalid timestamp.
    """
    if not isinstance(cell, str):
        return None

    cell = cell.replace(" ", "")
    cell = cell.split("-")[0].strip()
    cell = cell.split(",")[0].strip()

    return cell


def save_excel_sheets_as_csv(excel_file: str) -> List[str]:
    """
    Saves each sheet in an Excel file as a separate CSV file.

    :param excel_file: Excel file path.
    :return: List of sheet names saved as separate CSV files.
    """
    saved = []
    excel_data = pd.ExcelFile(excel_file)

    for sheet_name in excel_data.sheet_names:
        df = excel_data.parse(sheet_name)
        csv_file = f"{sheet_name}.csv"
        df.to_csv(csv_file, index=False)
        saved.append(csv_file)

    return saved

def convert_to_seconds(time: str) -> float:
    """
    Converts the given time string in format MM:SS.ff to seconds.

    :param time: Time string in format MM:SS.ff to be converted.
    :return: Number of seconds that the given time string represents.
    """
    if not time:
        return None
    time_chunks = time.split(":")
    result = 0
    for chunk_index, chunk in enumerate(reversed(time_chunks)):
        result += float(chunk) * math.pow(60, chunk_index)
    return result


def verify_time_cell(time: str) -> Optional[str]:
    """
    Converts the given cell to the valid QLab time format ("%H:%M:%S.%f").

    :param time: Cell with the time stamp to be converted.
    :return: Time string in the format "%H:%M:%S.%f", or None if the cell is not a valid time stamp.
    """
    time = sanitize_cell(time)

    try:
        time_obj = datetime.datetime.strptime(time, CUE_TIME_FORMAT)
    except ValueError:
        try:
            time_obj = datetime.datetime.strptime(time, CUE_TIME_FORMAT_MS)
        except ValueError:
            try:
                time_obj = datetime.datetime.strptime(time, CUE_TIME_FORMAT_HOURS)
                time_stamp = datetime.datetime.strftime(time_obj, CUE_TIME_FORMAT_HOURS_DECIMAl)
                return time_stamp[:-4]
            except ValueError:
                try:
                    time_obj = datetime.datetime.strptime(time, CUE_TIME_FORMAT_COLONS)
                except ValueError:
                    try:
                        time_obj = datetime.datetime.fromtimestamp(float(time))
                    except ValueError:
                        try:
                            time_obj = parse(time)
                        except ParserError:
                            return None

    #TODO: clean up
    time_stamp = datetime.datetime.strftime(time_obj, CUE_TIME_FORMAT_MS)
    return time_stamp[:-4]

def find_cell(csv_file: str, value: str) -> List[Tuple[int, int]]:
    """
    Finds the rows and columns of all cells with the specified value.

    :param csv_file: CSV file to search in.
    :param value: Value to search for (will be cast to string for comparison).
    :return: List with rows and columns of cells matching the given value.
    """
    matches = []

    with open(csv_file, 'r') as file:
        reader = csv.reader(file)
        for row_num, row in enumerate(reader):
            if row_num > 1000:
                break
            for col_num, cell in enumerate(row):
                if col_num > 1000:
                    break
                if cell.strip() == value.strip():
                    matches.append((row_num, col_num))
    return matches

def parse_times(csv_file: str, times_position: Tuple[int, int]) -> Optional[List[str]]:
    """
    Returns the list of times to be input into QLab given the position of the "Cue Start Time" cell position.

    :param csv_file: CSV file to search in.
    :param times_position: Position of the "Cue Start Time" cell position.
    :return: List of times to be input into QLab.
    """
    times = []
    target_row_num, target_col_num = times_position

    with open(csv_file, 'r') as file:
        reader = csv.reader(file)
        for row_num, row in enumerate(reader):
            if row_num > 1000:
                break
            for col_num, cell in enumerate(row):
                if col_num > 1000:
                    break
                if col_num == target_col_num and row_num > target_row_num:
                    verified_time = convert_to_seconds(verify_time_cell(cell))
                    if not verified_time and row_num > target_row_num + EMPTY_TIME_CELL_TOLERANCE:
                        return times
                    if verified_time:
                        times.append(verified_time)

    return times

def extract_tables(excel_file: str) -> [List[List[str]]]:
    """
    Extracts time stamp information from all sheets in the Excel file to be used in QLab.

    :param excel_file: Excel file path.
    :return: List of time stamp information extracted from all sheets.
    """
    time_stamps = dict()

    csv_files = save_excel_sheets_as_csv(excel_file)
    for csv_file in csv_files:
        group_name = csv_file.split(".csv")[0]
        cue_groups = []
        found_time_cells = find_first_cell_occurrences(csv_file, CUE_TIME_LABELS)
        found_example_cells = find_first_cell_occurrences(csv_file, EXAMPLE_LABELS)

        found_time_cells = remove_example_tables(found_time_cells, found_example_cells)

        #TODO: skip typos

        if len(found_time_cells) > 1:
            time_stamps[group_name] = dict()
        for found_cell_num, found_cell in enumerate(found_time_cells):
            extracted_times = parse_times(csv_file, found_cell)
            extracted_times = [time for time in extracted_times if time is not None]
            cue_groups.append(extracted_times)
            if len(found_time_cells) == 1:
                time_stamps[group_name] = extracted_times
            else:
                time_stamps[group_name][f"Part {found_cell_num + 1}"] = extracted_times

        try:
            os.remove(csv_file)
        except FileNotFoundError:
            pass

    return time_stamps

def sanitize_filepath(filepath: str) -> str:
    """
    Sanitizes the path to the Excel file to make it Python-appropriate.

    :param filepath: Path to the Excel file.
    :return: Sanitized path.
    """
    new_path = filepath.replace("file://", "")
    new_path = new_path.replace("\\", "/")
    new_path = new_path.replace("%20", " ")

    return new_path