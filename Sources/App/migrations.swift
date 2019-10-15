import FluentPostgreSQL
import Vapor

struct AddFieldsToUser: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.update(User.self, on: connection) { builder in
            //builder.field(for: \.score)
            //builder.field(for: \.updatedAt)
            //builder.field(for: \.deletedAt)
            
        }
    }
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.update(User.self, on: connection) { builder in
            //builder.deleteField(for: \.score)
            //builder.deleteField(for: \.updatedAt)
            //builder.deleteField(for: \.deletedAt)
        }
    }
}

