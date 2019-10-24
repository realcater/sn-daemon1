@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class GameTests: XCTestCase {
    let usersName = "Dima"
    let usersPassword = "password"
    let usersURI = "/api/users/"
    let gamesName = "Game-A02"
    let gamesPassword = "password"
    let playersQty = 4
    let gamesURI = "/api/games/"
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
    
    func testGettingAllGamesFromTheAPI() throws {
        let game = try Game.create(name: gamesName, on: conn)
        
        let games = try app.getResponse(
            to: gamesURI,
            decodeTo: [Game.Public].self,
            loggedInRequest: false)
        
        XCTAssertEqual(games.count, 1)
        XCTAssertEqual(games[0].name, gamesName)
        XCTAssertEqual(games[0].id, game.id)
    }
    
    func testGettingASingleGameFromTheAPI() throws {
        let game = try Game.create(name: gamesName, on: conn)
        
        let receivedgame = try app.getResponse(
            to: "\(gamesURI)\(game.id!)",
            decodeTo: Game.Public.self,
            loggedInRequest: true)
        
        XCTAssertEqual(receivedgame.name, gamesName)
        XCTAssertEqual(receivedgame.id, game.id)
    }
    
    func testGameCanBeDeletedWithAPI() throws {
        let user = try User.create(on: conn)
        
        let game = try Game.create(owner: user, on: conn)
        let response = try app.sendRequest(
            to: "\(gamesURI)\(game.id!)",
            method: .DELETE,
            loggedInRequest: true,
            loggedInUser: user)
        
        let games = try app.getResponse(
            to: gamesURI,
            decodeTo: [Game.Public].self,
            loggedInRequest: true)
        
        XCTAssertEqual(response.http.status, .noContent)
        XCTAssertEqual(games.count, 0)
    }
    
    func testGameCanBeSavedWithAPI() throws {
        let user = try User.create(name: usersName, on: conn)
        let game = Game(name: gamesName, password: gamesPassword, playersQty: playersQty, userID1: user.id!)
        let receivedgame = try app.getResponse(
            to: gamesURI,
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: game,
            decodeTo: Game.Public.self,
            loggedInRequest: true)
        
        XCTAssertEqual(receivedgame.name, gamesName)
        XCTAssertNotNil(receivedgame.id)
        
        let games = try app.getResponse(
            to: gamesURI,
            decodeTo: [Game.Public].self,
            loggedInRequest: true)
        
        XCTAssertEqual(games.count, 1)
        XCTAssertEqual(games[0].name, gamesName)
        XCTAssertEqual(games[0].id, receivedgame.id)
    }
    
    
    
}
