import FluentPostgreSQL
import Vapor
import Authentication

final class User: Codable {
    var id: UUID?
    var name: String
    var password: String
    var score: Int?
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    init(name: String, password: String) {
        self.name = name
        self.password = password
    }
    final class Public: Codable {
        var id: UUID?
        var name: String
        var score: Int?
        
        init(id: UUID?, name: String, score: Int?) {
            self.id = id
            self.name = name
            self.score = score
        }
    }
}

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, name: name, score: score)
    }
    func getName() -> String {
        return name
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
    func getName() -> Future<String> {
        return self.map(to: String.self) { user in
            return user.name
        }
    }
}

extension User: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.name)
            builder.field(for: \.password)
            builder.field(for: \.score)
            builder.field(for: \.createdAt)
            builder.field(for: \.updatedAt)
            builder.field(for: \.deletedAt)
            
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
        let user = User(name: "admin", password: hashedPassword)
        return user.save(on: connection).transform(to: ())
    }
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return .done(on: connection)
    }
}

struct AppUser: Migration {
    typealias Database = PostgreSQLDatabase
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        guard let passwordString = Environment.get("APP_PASSWORD") else {
            fatalError("APP_PASSWORD ENV is not set")
        }
        let password = try? BCrypt.hash(passwordString)
        guard let hashedPassword = password else {
            fatalError("Failed to create app user")
        }
        let user = User(name: "app", password: hashedPassword)
        return user.save(on: connection).transform(to: ())
    }
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return .done(on: connection)
    }
}

extension User: PostgreSQLUUIDModel {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static let deletedAtKey: TimestampKey? = \.deletedAt
}
extension User: Content {}
extension User.Public: Content {}
extension User: Parameter {}
