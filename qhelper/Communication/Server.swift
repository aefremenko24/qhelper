//
//  Server.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/25/24.
//

import Foundation

struct QLabResponse: Codable {
    let status: String
    let data: String
    let workspace_id: String
    let address: String
}

class Server: ObservableObject {
    /// New data will be placed in this variable to be received by observers
    @Published public var messageReceived: QLabResponse?

    /// Collected /new responses for the current batch
    private var collectedResponses: [QLabResponse] = []
    /// Expected number of responses to wait for
    private var expectedResponseCount: Int = 0
    /// Continuation to resume when all expected responses have been collected
    private var waitContinuation: CheckedContinuation<[QLabResponse], Never>?

    /// Registers this server as the message receiver on the given TCP connection.
    func bind(to connection: QLAbConnection) {
        connection.onMessageReceived = { [weak self] data in
            self?.handleReceivedData(data)
        }
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

    private func handleReceivedData(_ data: Data) {
        if is_new_cue_response(response: data) {
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
    }
}
