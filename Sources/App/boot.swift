import Vapor
import Fluent

public func boot(_ app: Application) throws {
    let request = Request(using: app)
    func runRepeatTimer() throws {
        app.eventLoop.scheduleTask(in: TimeAmount.minutes(1), runRepeatTimer)
        _ = try TokenController.deleteExpiredTokens(request).map { deletedQty in
            print(deletedQty)
        }
    }
    try runRepeatTimer()
}
