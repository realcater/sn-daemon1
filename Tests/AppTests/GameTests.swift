@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class GameTests: XCTestCase {
    let usersName = "Dima"
    let usersName2 = "Lena"
    let usersPassword = "password"
    let usersURI = "/api/users/"
    let gamesName = "Game-A02"
    let gamesPassword = "password"
    let usersQty = 4
    let gamesURI = "/api/games/"
    let mainUserRoles: [Player] = [K.redSpymaster]
    let cards: [Card] = K.testCards
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
        
        let receivedGame = try app.getResponse(
            to: "\(gamesURI)\(game.id!)",
            decodeTo: Game.Public.self,
            loggedInRequest: true)
        
        XCTAssertEqual(receivedGame.name, gamesName)
        XCTAssertEqual(receivedGame.id, game.id)
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
        let game = Game(name: gamesName, password: gamesPassword, usersQty: usersQty, mainUserID: user.id!,mainUserRoles: mainUserRoles, cards: K.testCards)
        let receivedgame = try app.getResponse(
            to: gamesURI,
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: game,
            decodeTo: Game.Public.self,
            loggedInRequest: true,
            loggedInUser: user)
        
        XCTAssertEqual(receivedgame.name, gamesName)
        XCTAssertNotNil(receivedgame.id)
        
        let games = try app.getResponse(
            to: gamesURI,
            decodeTo: [Game.Public].self,
            loggedInRequest: true,
            loggedInUser: user)
        
        XCTAssertEqual(games.count, 1)
        XCTAssertEqual(games[0].name, gamesName)
        XCTAssertEqual(games[0].id, receivedgame.id)
    }
    
    func testGameCanBeUpdatedWithAPI() throws {
        let user = try User.create(name: usersName, on: conn)
        let user2 = try User.create(name: usersName2, on: conn)
        let game = try Game.create(owner: user, on: conn)
        
        let updatedData = GameUpdateData(userID2: user2.id, isGameStarted: true, isGameFinished: true, startTeam: K.redTeam, usersOrder: [0,3,2])
        
        let updatedGame = try app.getResponse(
            to: "\(gamesURI)\(game.id!)",
            method: .PUT,
            headers: ["Content-Type": "application/json"],
            data: updatedData,
            decodeTo: Game.Public.self,
            loggedInRequest: true,
            loggedInUser: user)
        
        XCTAssertEqual(updatedGame.userID2, user2.id)
        XCTAssertEqual(updatedGame.isGameStarted, true)
        XCTAssertEqual(updatedGame.isGameFinished, true)
        
        let receivedGame = try app.getResponse(
            to: "\(gamesURI)\(game.id!)",
            decodeTo: Game.Public.self,
            loggedInRequest: true)
        
        XCTAssertEqual(receivedGame.userID2, user2.id)
        XCTAssertEqual(receivedGame.isGameStarted, true)
        XCTAssertEqual(receivedGame.isGameFinished, true)
    }
}
