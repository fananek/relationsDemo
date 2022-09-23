import Vapor

struct LoginInfo: Content {
    var loginRequired: Bool
    var loginFailed: Bool
    var redirectUrl: String?
}
