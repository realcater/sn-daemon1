@testable import App
import FluentPostgreSQL

extension User {
    static func create(
            name: String,
            on connection: PostgreSQLConnection) throws -> User {
        let user = User(name: name, password: "password")
        return try user.save(on: connection).wait()
    }
}
