import Vapor

final class AdminUserAuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let user = try request.requireAuthenticated(User.self)
        if user.name != "admin" {
            throw Abort(.forbidden)
        } else {
            return try next.respond(to: request)
        }
    }
}

final class AppUserAuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let user = try request.requireAuthenticated(User.self)
        if user.name != "app" && user.name != "admin" {
            throw Abort(.forbidden)
        } else {
            return try next.respond(to: request)
        }
    }
}
