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
    
    func listen_for_messages() {
        self.connection?.receiveMessage { [weak self] data, context, isComplete, error in
            guard let self = self else { return }
            
            if let data = data, is_new_cue_response(response: data) {
                if let decoded = decode_qlab_response(data: data) {
                    DispatchQueue.main.async {
                        self.messageReceived = decoded
                    }
                }
            }

            if self.listening {
                self.listen_for_messages()
            }
        }
    }
    
    func cancel() {
        self.listening = false
        self.connection?.cancel()
    }
}
