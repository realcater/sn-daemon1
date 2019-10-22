import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let usersController = UsersController()
    try router.register(collection: usersController)
    
    let gamesController = GamesController()
    try router.register(collection: gamesController)
    
    let tokensController = TokensController()
    try router.register(collection: tokensController)
}
