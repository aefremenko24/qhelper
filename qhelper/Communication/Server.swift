//
//  Server.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/25/24.
//

import Foundation
import OSCKit

class Server {
    var oscServer: OSCServer
    var responses: [OSCMessage] = []

    init(port: UInt16) {
        self.oscServer = OSCServer(port: port)
    }
    
    func start() async throws {
        try await oscServer.start()
        
        await self.oscServer.setHandler { [weak self] oscMessage, timeTag in
            do {
                try self?.handle(received: oscMessage)
            } catch {
                print(error)
            }
        }
    }

    private func handle(received oscMessage: OSCMessage) throws {
        responses.append(oscMessage)
    }
}
