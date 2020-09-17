//
//  BrowserBridge.swift
//  BrowserBridge
//
//  Created by Thies C. Arntzen on 13.09.20.
//

import Foundation
import Network

public class WebSocketServer {
    public class Connection {
        let connection: NWConnection

        public var onData: ((Data) -> Void)?
        public var onClose: ((String) -> Void)?

        deinit {
            print("\(self) deinit")
        }

        init(connection: NWConnection, on queue: DispatchQueue) {
            self.connection = connection
            
            connection.stateUpdateHandler = { state in
    //            print("Connection.stateUpdateHandler", state)
            }

            setupReceiveMessage()
            connection.start(queue: queue)
        }
        
        public func send(data: Data) {
            let context = NWConnection.ContentContext(
                identifier: "context", metadata: [
                    NWProtocolWebSocket.Metadata(opcode: .text)
            ])
            
            let completion = NWConnection.SendCompletion.contentProcessed { [weak self] error in
                if let error = error {
                    self?.close("\(error)")
                } else {
    //                print("sent \(String(data: data, encoding: .utf8) ?? "?")")
                }
            }
            
            connection.send(
                content: data,
                contentContext: context,
                isComplete: true,
                completion: completion)
        }

        private func setupReceiveMessage() {
            connection.receiveMessage(completion: messageReceived)
        }
        
        private func messageReceived(data: Data?, context: NWConnection.ContentContext?, isComplete: Bool, error: NWError?) {
            if let error = error {
                close("\(error)")
            } else if let data = data {
                setupReceiveMessage()
                onData?(data)
            } else {
                close("!data && !error")
            }
        }

        private func close(_ reason: String) {
            connection.stateUpdateHandler = nil
            connection.cancel()
            onClose?(reason)
            onData = nil
            onClose = nil
        }
    }

    let listener: NWListener
    let queue: DispatchQueue

    public var onConnection: ((Connection) -> Void)?
    public var onConnectionClosed: ((Connection) -> Void)?

    public init(port: UInt16, queue: DispatchQueue = .main) {
        let wsOptions = NWProtocolWebSocket.Options()
        wsOptions.autoReplyPing = true

        let parameters = NWParameters(tls: .none)
        parameters.allowLocalEndpointReuse = true
        parameters.includePeerToPeer = true
        parameters.defaultProtocolStack.applicationProtocols.insert(wsOptions, at: 0)

        self.listener = try! NWListener(using: parameters, on: NWEndpoint.Port(rawValue: port)!)
        self.queue = queue
    }
    
    public func start() {
        listener.stateUpdateHandler = { state in
            if case NWListener.State.failed(let reason) = state {
                fatalError("stateUpdateHandler \(reason)")
            } else {
//                print("stateUpdateHandler", state)
            }
        }
            
        listener.newConnectionHandler = { connection in
            let connection = Connection(connection: connection, on: self.queue)
            
            connection.onClose = { reason in
//                print("connection.onClose \(reason) \(connection)")
                self.onConnectionClosed?(connection)
            }
            
            self.onConnection?(connection)
        }
        
        listener.start(queue: queue)
    }
}
