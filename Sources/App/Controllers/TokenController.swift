import Vapor
import Crypto
import Fluent

struct TokenController: RouteCollection {
    func boot(router: Router) throws {
        let tokensRoute = router.grouped("api", "tokens")
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let adminUserAuthMiddleware = AdminUserAuthMiddleware()
        
        let adminAuthGroup = tokensRoute.grouped(
            basicAuthMiddleware,
            adminUserAuthMiddleware)
        
        adminAuthGroup.delete(use: TokenController.deleteExpiredTokens)
    }
    
    static func deleteExpiredTokens(_ req: Request) throws -> Future<String> {
        let filterQuery = Token.query(on: req).filter(\.expiredAt < Date())
        return filterQuery.count().flatMap { count in
            return filterQuery.delete().transform(to: "\(count) tokens deleted")
        }
    }
}
