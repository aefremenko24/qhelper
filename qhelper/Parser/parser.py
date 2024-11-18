#!/usr/bin/env python3.9

import csv
import datetime
import json
import re
import sys

import pandas as pd

from typing import Tuple, List, Optional

CUE_TIME_REGEX = r"^([0-5]?[0-9]):[0-5][0-9].?[0-9]?[0-9]?$"
CUE_TIME_FORMAT = "%H:%M:%S"
CUE_TIME_FORMAT_MS = "%H:%M:%S.%f"

CUE_TIME_LABELS = ["Cue Start Time", "QLAB TIMING"]

EMPTY_TIME_CELL_TOLERANCE = 2

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


def verify_time_cell(time: str) -> Optional[str]:
    """
    Converts the given cell to the valid QLab time format ("%H:%M:%S.%f").

    :param time: Cell with the time stamp to be converted.
    :return: Time string in the format "%H:%M:%S.%f", or None if the cell is not a valid time stamp.
    """
    time = time.strip()

    if not isinstance(time, str):
        return None
    if "-" in time:
        time = time.split("-")[0]

    if not re.match(CUE_TIME_REGEX, time):
        return None

    try:
        time_obj = datetime.datetime.strptime(time, CUE_TIME_FORMAT)
    except ValueError:
        try:
            time_obj = datetime.datetime.strptime(time, CUE_TIME_FORMAT_MS)
        except ValueError:
            return None

    return datetime.datetime.strftime(time_obj, CUE_TIME_FORMAT)

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
                    if not verify_time_cell(cell) and row_num > target_row_num + EMPTY_TIME_CELL_TOLERANCE:
                        break
                    if verify_time_cell:
                        times.append(verify_time_cell(cell))

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
        cue_groups = []
        found_cells = []
        for label in CUE_TIME_LABELS:
            found_cells = find_cell(csv_file, label)
            if found_cells:
                break
        for found_cell in found_cells:
            extracted_times = parse_times(csv_file, found_cell)
            extracted_times = [time for time in extracted_times if time is not None]
            time_stamps[csv_file] = extracted_times

    return time_stamps

if __name__ == "__main__":
    if len(sys.argv) < 2:
        raise Exception("Please provide an excel file path.")
    json.dump(extract_tables(sys.argv[1]), sys.stdout, indent=4)