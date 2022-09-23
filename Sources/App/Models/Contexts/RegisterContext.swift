struct RegisterContext: GenericContext {
    var title: String
    var description: String
    var userExists: Bool
    var userEmail: String?
    var passwordsMismatch: Bool
    var redirectUrl: String?
}
