//
//  Server.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/25/24.
//

import Foundation
import Network
import OSCKit

struct QLabResponse: Codable {
    let status: String
    let data: String
    let workspace_id: String
    let address: String
}

class Server: ObservableObject {
    var listener: NWListener?
    var connection: NWConnection?
    var queue = DispatchQueue.global(qos: .userInitiated)
    /// New data will be place in this variable to be received by observers
    @Published public var messageReceived: QLabResponse?
    /// When there is an active listening NWConnection this will be `true`
    @Published private(set) public var isReady: Bool = false
    /// Default value `true`, this will become false if the UDPListener ceases listening for any reason
    @Published public var listening: Bool = true

    /// Collected /new responses for the current batch
    private var collectedResponses: [QLabResponse] = []
    /// Expected number of responses to wait for
    private var expectedResponseCount: Int = 0
    /// Continuation to resume when all expected responses have been collected
    private var waitContinuation: CheckedContinuation<[QLabResponse], Never>?
    
    
    /// A convenience init using Int instead of NWEndpoint.Port
    convenience init(port: Int) {
        self.init(on: NWEndpoint.Port(integerLiteral: NWEndpoint.Port.IntegerLiteralType(port)))
    }
    /// Use this init or the one that takes an Int to start the listener
    init(on port: NWEndpoint.Port) {
        let params = NWParameters.udp
        params.allowFastOpen = true
        self.listener = try? NWListener(using: params, on: port)
        self.listener?.stateUpdateHandler = { update in
            switch update {
            case .ready:
                self.isReady = true
            case .failed, .cancelled:
                self.listening = false
                self.isReady = false
            default:
                break
            }
        }
        self.listener?.newConnectionHandler = { connection in
            self.createConnection(connection: connection)
        }
        self.listener?.start(queue: self.queue)
    }
    
    func createConnection(connection: NWConnection) {
        self.connection = connection
        self.connection?.stateUpdateHandler = { (newState) in
            switch (newState) {
            case .ready:
                self.listen_for_messages()
            case .cancelled, .failed:
                self.listener?.cancel()
                self.listening = false
            default:
                break
            }
        }
        self.connection?.start(queue: .global())
    }
    
    /// Resets response collection state for a new batch of commands.
    /// Must be called on the main thread before sending commands.
    func resetResponseCollection() {
        collectedResponses.removeAll()
        expectedResponseCount = 0
        if let continuation = waitContinuation {
            waitContinuation = nil
            continuation.resume(returning: [])
        }
    }

    /// Waits until the specified number of /new responses have been collected from QLab.
    /// Returns the collected responses once all have arrived, or after the timeout.
    func waitForResponses(count: Int, timeout: TimeInterval = 30.0) async -> [QLabResponse] {
        if count <= 0 { return [] }

        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                self.expectedResponseCount = count
                if self.collectedResponses.count >= count {
                    continuation.resume(returning: self.collectedResponses)
                } else {
                    self.waitContinuation = continuation

                    // Safety timeout to avoid hanging forever
                    DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { [weak self] in
                        guard let self = self else { return }
                        if let pending = self.waitContinuation {
                            self.waitContinuation = nil
                            pending.resume(returning: self.collectedResponses)
                        }
                    }
                }
            }
        }
    }

    func listen_for_messages() {
        self.connection?.receiveMessage { [weak self] data, context, isComplete, error in
            guard let self = self else { return }

            if let data = data, is_new_cue_response(response: data) {
                if let decoded = decode_qlab_response(data: data) {
                    DispatchQueue.main.async {
                        self.messageReceived = decoded
                        self.collectedResponses.append(decoded)

                        if self.collectedResponses.count >= self.expectedResponseCount,
                           let continuation = self.waitContinuation {
                            self.waitContinuation = nil
                            continuation.resume(returning: self.collectedResponses)
                        }
                    }
                }
            }

            if self.listening {
                return self.listen_for_messages()
            }
        }
    }

    func cancel() {
        self.listening = false
        self.connection?.cancel()
    }
}
