struct LoginContext: GenericContext {
    var title: String
    var description: String
    var isLoginRequired: Bool
    var isLoginFailed: Bool
    var redirectUrl: String?
}
