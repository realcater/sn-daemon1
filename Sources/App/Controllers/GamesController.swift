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
        let game = try Game(name: data.name, password: password, usersQty: data.usersQty, mainUserID: user.requireID(), mainUserRoles: data.mainUserRoles, cards: data.cards)
        return game.save(on: req).convertToPublic()
    }
    
    func update(_ req: Request) throws -> Future<Game.Public> {
        let user = try req.requireAuthenticated(User.self)
        return try flatMap(to: Game.Public.self,
                           req.parameters.next(Game.self),
                           req.content.decode(GameUpdateData.self)) { game, updateData in
                            guard game.mainUserID == user.id else { throw Abort(.forbidden) }
                            if let userID = updateData.userID1 {
                                game.userID1 = userID }
                            if let userID = updateData.userID2 {
                                game.userID2 = userID }
                            if let userID = updateData.userID3 {
                                game.userID3 = userID }
                            if let isGameStarted = updateData.isGameStarted {
                                game.isGameStarted = isGameStarted
                            }
                            if let isGameFinished = updateData.isGameFinished {
                                game.isGameFinished = isGameFinished
                            }
                            if let startTeam = updateData.startTeam {
                                game.startTeam = startTeam }
                            if let usersOrder = updateData.usersOrder {
                                game.usersOrder = usersOrder }
                            return game.save(on: req).convertToPublic()
        }
    }
    
    func delete(_ req: Request) throws -> Future<HTTPResponse> {
        let user = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Game.self).flatMap { game in
            guard game.mainUserID == user.id else { throw Abort(.forbidden) }
            return game.delete(force: true, on: req).transform(to: HTTPResponse(status: .noContent))
        }
    }
}

struct GameCreateData: Content {
    let name: String
    let password: String
    let usersQty: Int
    let mainUserRoles: [Player]
    let cards: [Card]
    
}

struct GameUpdateData: Content {
    let userID1: User.ID?
    let userID2: User.ID?
    let userID3: User.ID?
    let isGameStarted: Bool?
    let isGameFinished: Bool?
    let startTeam: Int?
    let usersOrder: [Int]?
    init(userID1: User.ID? = nil, userID2: User.ID? = nil, userID3: User.ID? = nil, isGameStarted: Bool? = nil, isGameFinished: Bool? = nil, startTeam: Int? = nil, usersOrder: [Int]? = nil) {
        self.userID1 = userID1
        self.userID2 = userID2
        self.userID3 = userID3
        self.isGameStarted = isGameStarted
        self.isGameFinished = isGameFinished
        self.startTeam = startTeam
        self.usersOrder = usersOrder
    }
}

