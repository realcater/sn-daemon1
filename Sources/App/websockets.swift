import Vapor

public func sockets(_ websockets: NIOWebSocketServer) {
    
    func echo(ws: WebSocket, req: Request) throws -> () {
        print("ws connnected")
        ws.onText { ws, text in
            print("ws received: \(text)")
            ws.send("echo - \(text)")
        }
    }
    func showUser(ws: WebSocket, req: Request) throws -> () {
        print("show user")
        let fUser: Future<User> = try UsersController.getByName(req, name: "admin")
        ws.onText { ws, text in
            print("ws received: \(text)")
            _ = fUser.map {
                ws.send("echo - \($0.name)")
            }
        }
    }
    
    websockets.get("echo-test", use: echo)
    websockets.get("users", use: showUser)
}
