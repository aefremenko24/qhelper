//
//  Validations.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/30/24.
//

import Foundation

/**
 Validates that the host provided is not empty.
 
 - Parameter host: Host to be validated.
 - Returns: true if the host is valid, false otherwise.
 */
func validateHost(host: String) -> Bool {
    return !host.isEmpty
}

/**
 Validates that the provided port number is of length 1 through 5 characters, inclusive, and only contains numbers.
 
 - Parameter port: Port to be validated.
 - Returns: true if the port is valid, false otherwise.
 */
func validatePort(port: String) -> Bool {
    if port.count < 1 || port.count > 5 {
        return false
    }
    if !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: port)) {
        return false
    }
    return true
}

/**
 Validates that the provided QLab passcode only contains numbers.
 
 - Parameter passcode: Passcode to be validated.
 - Returns: true if the passcode is valid, false otherwise.
 */
func validatePassCode(passcode: String) -> Bool {
    return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: passcode))
}

/**
 Validates that the workspace name provided is not empty.
 
 - Parameter workspace: Workspace name to be validated.
 - Returns: true if the workspace name is valid, false otherwise.
 */
func validateWorkspace(workspace: String) -> Bool {
    return !workspace.isEmpty
}
