import FluentPostgreSQL
import Vapor

final class Users: Codable {
    var id: UUID?
    var name: String
    var password: String

    init(id: UUID?, name: String, password: String) {
        self.id = id
        self.name = name
        self.password = password
    }
}

extension Users: PostgreSQLUUIDModel {}
extension Users: Migration { }
extension Users: Content { }
extension Users: Parameter {}
