import Foundation
import BrowserBridge

print("start")

let echoServer = WebSocketServer(port: 3001)
echoServer.start()

echoServer.onConnection = { connection in
    _ = connection
    
    connection.onData = { data in
        print("data received", String(data: data, encoding: .utf8) ?? "-")
        connection.send(data: data)
    }
}

RunLoop.current.run()
