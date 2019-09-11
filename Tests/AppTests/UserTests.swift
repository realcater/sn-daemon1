
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
        let user = try User.create(name: usersName, on: conn)
        
        let users = try app.getResponse(
            to: usersURI,
            decodeTo: [User.Public].self,
            loggedInRequest: true)
        
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[1].name, usersName)
        XCTAssertEqual(users[1].id, user.id)
    }
    
    func testGettingASingleUserFromTheAPI() throws {
        let user = try User.create(name: usersName, on: conn)
        
        let receivedUser = try app.getResponse(
            to: "\(usersURI)\(user.id!)",
            decodeTo: User.Public.self,
            loggedInRequest: true)
        
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.id, user.id)
    }

    func testUserCanBeDeletedWithAPI() throws {
        let user = try User.create(name: usersName, on: conn)
        
        let response = try app.sendRequest(
            to: "\(usersURI)\(user.id!)",
            method: .DELETE,
            loggedInRequest: true)
        
        let users = try app.getResponse(
            to: usersURI,
            decodeTo: [User.Public].self,
            loggedInRequest: true)
        
        XCTAssertEqual(response.http.status, .noContent)
        XCTAssertEqual(users.count, 1)
    }
    
    func testUserCanBeSavedWithAPI() throws {
        let user = User(name: usersName, password: usersPassword)
        let receivedUser = try app.getResponse(
            to: usersURI,
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: user,
            decodeTo: User.Public.self,
            loggedInRequest: true)
        
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertNotNil(receivedUser.id)
        
        let users = try app.getResponse(
            to: usersURI,
            decodeTo: [User.Public].self,
            loggedInRequest: true)
        
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[1].name, usersName)
        XCTAssertEqual(users[1].id, receivedUser.id)
    }
    
    
    
}
