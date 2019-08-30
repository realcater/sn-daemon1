import Vapor

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        usersRoute.get(use: index)
        usersRoute.post(use: create)
        usersRoute.delete(Users.parameter, use: delete)
    }
    
    func index(_ req: Request) throws -> Future<[Users]> {
        return Users.query(on: req).all()
    }

    func create(_ req: Request) throws -> Future<Users> {
        return try req.content.decode(Users.self).flatMap { user in
            return user.save(on: req)
        }
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Users.self).delete(on: req).transform(to: .noContent)
    }
}
