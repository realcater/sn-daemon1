import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let userController = UsersController()
    try router.register(collection: userController)
    
    let tokenController = TokenController()
    try router.register(collection: tokenController)
}
