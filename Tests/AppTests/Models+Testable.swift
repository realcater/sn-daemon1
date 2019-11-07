@testable import App
import FluentPostgreSQL
import Crypto

extension User {
    static func create(
        name: String = "Dima",
            on connection: PostgreSQLConnection) throws -> User {
        let password = try BCrypt.hash("password")
        var user = User(name: name, password: password)
        user = try user.save(on: connection).wait()
        user.password = "password"
        return user
        }
    }
extension Game {
    static func create(name: String = "Game-A01", usersQty: Int = 4, owner: User? = nil, on connection: PostgreSQLConnection) throws -> Game {
        var gameOwner = owner
        if gameOwner == nil {
            gameOwner = try User.create(on: connection)
        }
        let password = try BCrypt.hash("password")
        let game = Game(name: name, password: password, usersQty: usersQty, mainUserID: gameOwner!.id!,mainUserRoles: [K.redSpymaster], cards: K.testCards)
        return try game.save(on: connection).wait()
    }
}
