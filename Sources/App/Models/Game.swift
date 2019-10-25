import FluentPostgreSQL
import Vapor
import Authentication

final class Game: Codable {
    var id: UUID?
    var name: String
    var password: String
    var playersQty: Int
    var userID1: User.ID

    var userID2: User.ID?
    var userID3: User.ID?
    var userID4: User.ID?
    var isGameStarted: Bool
    var isGameFinished: Bool
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    
    init(name: String, password: String, playersQty: Int, userID1: User.ID) {
        self.name = name
        self.password = password
        self.playersQty = playersQty
        self.userID1 = userID1
        self.isGameStarted = false
        self.isGameFinished = false
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var playersQty: Int
        var userID1: User.ID
        var userID2: User.ID?
        var userID3: User.ID?
        var userID4: User.ID?
        var isGameStarted: Bool
        var isGameFinished: Bool
        
        init(id: UUID?, name: String, playersQty: Int, userID1: User.ID, userID2: User.ID? = nil, userID3: User.ID? = nil, userID4: User.ID? = nil, isGameStarted: Bool, isGameFinished: Bool) {
            self.id = id
            self.name = name
            self.playersQty = playersQty
            self.userID1 = userID1
            self.userID2 = userID2
            self.userID3 = userID3
            self.userID4 = userID4
            self.isGameStarted = isGameStarted
            self.isGameFinished = isGameFinished
        }
    }
}

extension Game {
    func convertToPublic() -> Game.Public {
        return Game.Public(id: id, name: name, playersQty: playersQty, userID1: userID1, userID2: userID2, userID3: userID3, userID4: userID4, isGameStarted: isGameStarted, isGameFinished: isGameFinished)
    }
}

extension Future where T: Game {
    func convertToPublic() -> Future<Game.Public> {
        return self.map(to: Game.Public.self) { game in
            return game.convertToPublic()
        }
    }
}

extension Game: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID1, to: \User.id)
            builder.reference(from: \.userID2, to: \User.id)
            builder.reference(from: \.userID3, to: \User.id)
            builder.reference(from: \.userID4, to: \User.id)
            builder.unique(on: \.name)
        }
    }
}

extension Game: PostgreSQLUUIDModel {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static let deletedAtKey: TimestampKey? = \.deletedAt
}

extension Game {
    var user1: Parent<Game, User> {
        return parent(\.userID1)
    }
}

extension Game: Content {}
extension Game.Public: Content {}
extension Game: Parameter {}



