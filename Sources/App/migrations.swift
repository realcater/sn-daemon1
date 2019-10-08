import FluentPostgreSQL
import Vapor

/*
struct AddFieldsToUser: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.field(for: \.createdAt)
            builder.field(for: \.updatedAt)
            
        }
    }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.field(for: \.createdAt)
            builder.field(for: \.updatedAt)
        }
    }
}
*/
