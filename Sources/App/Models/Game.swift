import FluentPostgreSQL
import Vapor
import Authentication

class Card: Codable {
    var word: String
    var color: Int
    var _guessed: Bool
    init(word: String, color: Int, _guessed: Bool) {
        self.word = word
        self.color = color
        self._guessed = _guessed
    }
}

class Hint: Codable {
    var text: String
    var qty: Int
}

struct Place: Codable {
    var x: Int
    var y: Int
}

struct Player: Codable {
    var team: Int
    var type: Int
}

final class Game: Codable {
    var id: UUID?
    var name: String
    var password: String
    
    var mainUserID: User.ID
    var userID1: User.ID?
    var userID2: User.ID?
    var userID3: User.ID?
    
    var isGameStarted: Bool
    var isGameFinished: Bool
    
    var usersQty: Int
    var startTeam: Int?
    var usersOrder: [Int] = []
    var cards: [Card]
    var mainUserRoles: [Player]
    
    //var hints: [Hint] = []
    //var answers: [Place] = []
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    
    init(name: String, password: String, usersQty: Int, mainUserID: User.ID, mainUserRoles: [Player], cards: [Card]) {
        self.name = name
        self.password = password
        self.usersQty = usersQty
        self.mainUserID = mainUserID
        self.isGameStarted = false
        self.isGameFinished = false
        self.cards = cards
        self.mainUserRoles = mainUserRoles
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var usersQty: Int
        var mainUserID: User.ID
        var userID1: User.ID?
        var userID2: User.ID?
        var userID3: User.ID?
        var isGameStarted: Bool
        var isGameFinished: Bool
        var usersOrder: [Int]
        
        init(id: UUID?, name: String, usersQty: Int, mainUserID: User.ID, userID1: User.ID? = nil, userID2: User.ID? = nil, userID3: User.ID? = nil, isGameStarted: Bool, isGameFinished: Bool, usersOrder: [Int] = []) {
            self.id = id
            self.name = name
            self.usersQty = usersQty
            self.mainUserID = mainUserID
            self.userID1 = userID1
            self.userID2 = userID2
            self.userID3 = userID3
            self.isGameStarted = isGameStarted
            self.isGameFinished = isGameFinished
            self.usersOrder = usersOrder
        }
    }
}

extension Game {
    func convertToPublic() -> Game.Public {
        return Game.Public(id: id, name: name, usersQty: usersQty, mainUserID: mainUserID, userID1: userID1, userID2: userID2, userID3: userID3, isGameStarted: isGameStarted, isGameFinished: isGameFinished, usersOrder: usersOrder)
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
            builder.reference(from: \.mainUserID, to: \User.id)
            builder.reference(from: \.userID1, to: \User.id)
            builder.reference(from: \.userID2, to: \User.id)
            builder.reference(from: \.userID3, to: \User.id)
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
        return parent(\.mainUserID)
    }
}

extension Game: Content {}
extension Game.Public: Content {}
extension Game: Parameter {}
