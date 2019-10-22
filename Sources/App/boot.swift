import Vapor
import Fluent

public func boot(_ app: Application) throws {
    let request = Request(using: app)
    func runRepeatTimer() throws {
        app.eventLoop.scheduleTask(in: TimeAmount.minutes(10), runRepeatTimer)
        _ = try TokensController.deleteExpiredTokens(request).map { deletedQty in
            print(deletedQty)
        }
    }
    try runRepeatTimer()
}
