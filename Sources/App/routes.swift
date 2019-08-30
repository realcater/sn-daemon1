import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let userController = UsersController()
    try router.register(collection: userController)
}
