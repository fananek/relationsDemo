import Vapor

struct RegisterInfo: Content {
    var userExists: Bool
    var userEmail: String?
    var passwordsMismatch: Bool
    var redirectUrl: String?
}
