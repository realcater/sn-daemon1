
@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class UserTests: XCTestCase {
    let usersName = "Alice"
    let usersPassword = "password"
    let usersURI = "/api/users/"
    var app: Application!
    var conn: PostgreSQLConnection!
    
    override func setUp() {
        try! Application .reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }
    
    override func tearDown() {
        conn.close()
        try? app.syncShutdownGracefully()
    }
    
    func testUsersCanBeRetrievedFromAPI() throws {
        let user = try User.create(
            name: usersName,
            on: conn)
        
        let users = try app.getResponse(
            to: usersURI,
            decodeTo: [User.Public].self)
        
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[1].name, usersName)
        XCTAssertEqual(users[1].id, user.id)
    }
    
    func testUserCanBeSavedWithAPI() throws {
        let user = User(name: usersName, password: usersPassword)
        let receivedUser = try app.getResponse(
            to: usersURI,
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: user,
            decodeTo: User.self)
        
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.password, usersPassword)
        XCTAssertNotNil(receivedUser.id)
        
        let users = try app.getResponse(
            to: usersURI,
            decodeTo: [User].self)
        
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users[0].name, usersName)
        XCTAssertEqual(users[0].password, usersPassword)
        XCTAssertEqual(users[0].id, receivedUser.id)
    }
}
