import FluentPostgreSQL
import Vapor
import Authentication

final class User: Codable {
    var id: UUID?
    var name: String
    var password: String
    var email: String?

    init(name: String, password: String, email: String? = nil) {
        self.name = name
        self.password = password
        self.email = email
    }
    final class Public: Codable {
        var id: UUID?
        var name: String
        var email: String?
        
        init(id: UUID?, name: String, email: String?) {
            self.id = id
            self.name = name
            self.email = email
        }
    }
}

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, name: name, email: email)
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
}

extension User: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.name)
            builder.field(for: \.password)
            builder.unique(on: \.name)
        }
    }
}

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.name
    static let passwordKey: PasswordKey = \User.password
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

struct AdminUser: Migration {
    typealias Database = PostgreSQLDatabase
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        guard let passwordString = Environment.get("ADMIN_PASSWORD") else {
            fatalError("ADMIN_PASSWORD ENV is not set")
        }
        let password = try? BCrypt.hash(passwordString)
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }
        let user = User(
            name: "admin",
            password: hashedPassword)
        return user.save(on: connection).transform(to: ())
    }
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return .done(on: connection)
    }
}

extension User: PostgreSQLUUIDModel {}
extension User: Content {}
extension User.Public: Content {}
extension User: Parameter {}
