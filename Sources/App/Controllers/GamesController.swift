import Vapor
import Crypto
import Fluent

struct GamesController: RouteCollection {
    func boot(router: Router) throws {
        let gamesRoute = router.grouped("api", "games")
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = gamesRoute.grouped(
            tokenAuthMiddleware,
            guardAuthMiddleware)
        
        
        //tokenAuthGroup.get(use: getAll)
        gamesRoute.get(use: getAll)
        tokenAuthGroup.get(Game.parameter, use: getSingle)
        
        tokenAuthGroup.post(GameCreateData.self, use: create)
        tokenAuthGroup.put(Game.parameter, use: update)
        tokenAuthGroup.delete(Game.parameter, use: delete)
    }
    
    func getAll(_ req: Request) throws -> Future<[Game.Public]> {
        return Game.query(on: req).decode(data: Game.Public.self).all()
    }
    
    func getSingle(_ req: Request) throws -> Future<Game.Public> {
        return try req.parameters.next(Game.self).convertToPublic()
    }
    
    func create(_ req: Request, data: GameCreateData) throws -> Future<Game.Public> {
        let user = try req.requireAuthenticated(User.self)
        let password = try BCrypt.hash(data.password)
        let game = try Game(name: data.name, password: password, playersQty: data.playersQty, userID1: user.requireID())
        return game.save(on: req).convertToPublic()
    }
    
    func update(_ req: Request) throws -> Future<Game.Public> {
        return try flatMap(to: Game.Public.self,
                           req.parameters.next(Game.self),
                           req.content.decode(GameUpdateData.self)) { game, updateData in
                            if let userID = updateData.userID2 {
                                game.userID2 = userID }
                            if let userID = updateData.userID3 {
                                game.userID3 = userID }
                            if let userID = updateData.userID4 {
                                game.userID4 = userID }
                            if let isGameStarted = updateData.isGameStarted {
                                game.isGameStarted = isGameStarted
                            }
                            if let isGameFinished = updateData.isGameFinished {
                                game.isGameFinished = isGameFinished
                            }
                            return game.save(on: req).convertToPublic()
        }
    }
    
    func delete(_ req: Request) throws -> Future<HTTPResponse> {
        let user = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Game.self).flatMap { game in
            if game.userID1 != user.id {
                throw Abort(.forbidden)
            } else {
                return game.delete(force: true, on: req).transform(to: HTTPResponse(status: .noContent))
            }
        }
    }
}

struct GameCreateData: Content {
    let name: String
    let password: String
    let playersQty: Int
}

struct GameUpdateData: Content {
    let userID2: User.ID?
    let userID3: User.ID?
    let userID4: User.ID?
    let isGameStarted: Bool?
    let isGameFinished: Bool?
}

