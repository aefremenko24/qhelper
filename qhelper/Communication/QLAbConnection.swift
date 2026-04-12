//
//  QLAbConnection.swift
//  qhelper
//
//  Created by Arthur Efremenko on 4/12/26.
//

import Foundation
import Network

// MARK: - SLIP constants (RFC 1055)

private let SLIP_END: UInt8     = 0xC0
private let SLIP_ESC: UInt8     = 0xDB
private let SLIP_ESC_END: UInt8 = 0xDC
private let SLIP_ESC_ESC: UInt8 = 0xDD

/// Manages a TCP connection to a QLab workspace.
/// OSC messages are framed using the double-END SLIP protocol (RFC 1055)
/// as required by QLab's OSC-over-TCP implementation.
class QLAbConnection: ObservableObject {
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "com.qhelper.tcp", qos: .userInitiated)
    private var receiveBuffer = Data()

    @Published private(set) var isConnected: Bool = false

    /// Called on the TCP queue when a complete, deframed OSC message is received.
    var onMessageReceived: ((Data) -> Void)?

    /// Opens a TCP connection to the given host and port.
    /// Returns once the connection is in the `.ready` state.
    func connect(host: String, port: UInt16) async throws {
        disconnect()

        let nwHost = NWEndpoint.Host(host)
        guard let nwPort = NWEndpoint.Port(rawValue: port) else {
            throw QLAbConnectionError.invalidPort
        }

        let connection = NWConnection(host: nwHost, port: nwPort, using: .tcp)
        self.connection = connection

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            var resumed = false
            connection.stateUpdateHandler = { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .ready:
                    if !resumed {
                        resumed = true
                        DispatchQueue.main.async { self.isConnected = true }
                        self.receiveLoop()
                        continuation.resume()
                    }
                case .failed(let error):
                    DispatchQueue.main.async { self.isConnected = false }
                    if !resumed {
                        resumed = true
                        continuation.resume(throwing: error)
                    }
                case .cancelled:
                    DispatchQueue.main.async { self.isConnected = false }
                default:
                    break
                }
            }
            connection.start(queue: self.queue)
        }
    }

    /// Sends raw OSC data over the TCP connection using SLIP framing.
    func send(_ data: Data) {
        var framed = Data()
        framed.append(SLIP_END) // leading END flushes any garbage

        for byte in data {
            switch byte {
            case SLIP_END:
                framed.append(SLIP_ESC)
                framed.append(SLIP_ESC_END)
            case SLIP_ESC:
                framed.append(SLIP_ESC)
                framed.append(SLIP_ESC_ESC)
            default:
                framed.append(byte)
            }
        }

        framed.append(SLIP_END) // trailing END marks packet boundary

        connection?.send(content: framed, completion: .contentProcessed { error in
            if let error = error {
                print("TCP send error: \(error)")
            }
        })
    }

    /// Closes the TCP connection.
    func disconnect() {
        connection?.cancel()
        connection = nil
        receiveBuffer.removeAll()
        DispatchQueue.main.async {
            self.isConnected = false
        }
    }

    // MARK: - SLIP receive loop

    /// Continuously reads from the TCP stream, accumulates bytes in a buffer,
    /// and extracts complete SLIP-framed messages.
    private func receiveLoop() {
        guard let connection = connection else { return }

        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self = self else { return }

            if let data = data, !data.isEmpty {
                self.receiveBuffer.append(data)
                self.extractMessages()
            }

            if error != nil || isComplete {
                DispatchQueue.main.async { self.isConnected = false }
                return
            }

            self.receiveLoop()
        }
    }

    /// Scans the receive buffer for SLIP END delimiters and delivers
    /// each complete, decoded message via the callback.
    private func extractMessages() {
        while let endIndex = receiveBuffer.firstIndex(of: SLIP_END) {
            let packetSlice = receiveBuffer[receiveBuffer.startIndex..<endIndex]

            if !packetSlice.isEmpty {
                let decoded = slipDecode(packetSlice)
                if !decoded.isEmpty {
                    onMessageReceived?(decoded)
                }
            }

            // Remove the processed bytes including the END delimiter
            receiveBuffer.removeSubrange(receiveBuffer.startIndex...endIndex)
        }
    }

    /// Decodes SLIP escape sequences from a raw packet slice.
    private func slipDecode(_ data: Data) -> Data {
        var result = Data()
        var i = data.startIndex

        while i < data.endIndex {
            let byte = data[i]
            if byte == SLIP_ESC {
                let next = data.index(after: i)
                if next < data.endIndex {
                    switch data[next] {
                    case SLIP_ESC_END: result.append(SLIP_END)
                    case SLIP_ESC_ESC: result.append(SLIP_ESC)
                    default: result.append(data[next])
                    }
                    i = data.index(after: next)
                } else {
                    i = data.index(after: i)
                }
            } else {
                result.append(byte)
                i = data.index(after: i)
            }
        }

        return result
    }
}

enum QLAbConnectionError: Error {
    case invalidPort
}
