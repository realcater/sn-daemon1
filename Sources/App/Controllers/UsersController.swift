import Vapor
import Crypto
import Fluent

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let adminUserAuthMiddleware = AdminUserAuthMiddleware()
        let appUserAuthMiddleware = AppUserAuthMiddleware()
        
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        let tokenAuthGroup = usersRoute.grouped(
            tokenAuthMiddleware,
            guardAuthMiddleware)
        let adminAuthGroup = usersRoute.grouped(
            tokenAuthMiddleware,
            guardAuthMiddleware,
            adminUserAuthMiddleware)
        let appAuthGroup = usersRoute.grouped(
            tokenAuthMiddleware,
            guardAuthMiddleware,
            appUserAuthMiddleware)
        
        basicAuthGroup.post("login", use: login)
        
        //tokenAuthGroup.get(use: getAll)
        usersRoute.get(use: getAll)
        tokenAuthGroup.get(User.parameter, use: getSingle)
        
        appAuthGroup.post(User.self, use: create)
        adminAuthGroup.delete(User.parameter, use: delete)
        adminAuthGroup.post(UUID.parameter, "restore", use: restore)
        adminAuthGroup.delete(User.parameter, "force", use: forceDelete)

        
    }
    
    func login(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
    
    func getAll(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    
    func getSingle(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).convertToPublic()
    }

    func create(_ req: Request, user: User) throws -> Future<User.Public> {
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req).convertToPublic()
    }

    func delete(_ req: Request) throws -> Future<HTTPResponse> {
        let httpRes = HTTPResponse(status: .noContent)
        return try req.parameters.next(User.self).delete(on: req).transform(to: httpRes)
    }
    
    func restore(_ req: Request) throws -> Future<HTTPResponse> {
        let userID = try req.parameters.next(UUID.self)
        return User.query(on: req, withSoftDeleted: true)
                .filter(\.id == userID)
                .first().flatMap(to: HTTPResponse.self) { user in
                    guard let user = user else {
                        throw Abort(.notFound)
                    }
                    let httpRes = HTTPResponse(status: .ok, body: "Restored")
                    return user.restore(on: req).transform(to: httpRes)
            }
    }
    func forceDelete(_ req: Request) throws -> Future<HTTPResponse> {
        let httpRes = HTTPResponse(status: .noContent)
        return try req.parameters.next(User.self).flatMap(to: HTTPResponse.self) { user in
                    user.delete(force: true, on: req).transform(to: httpRes)
            }
    }
}
