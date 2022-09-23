import Fluent
import Vapor

struct BaseController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Unprotected routes
        routes.get("health", use: healthCheck)
        routes.get("", use: home)
        routes.get("login", use: login)
        routes.get("register", use: register)
        routes.post("register", use: handleRegister)

        // Routes protected by login
        let credentialRoutes = routes.grouped(User.credentialsAuthenticator())
        credentialRoutes.post("login", use: handleLogin)
        
        let protectMiddlware = User.redirectMiddleware { req -> String in
            req.logger.error(Logger.Message(stringLiteral: "Unauthorized access at route \(req.url.path)"))
            return "/login?loginRequired=true&redirectUrl=\(req.url.path)"
        }
        let protectedRoutes = routes.grouped(protectMiddlware)
        
        let authProtectedRoutes = protectedRoutes.grouped("auth")
        authProtectedRoutes.get("logout", use: handleLogout)

        let userController = UserController()
        authProtectedRoutes.get("profile", ":userID", use: userController.profile)

    }

    func healthCheck(req: Request) async throws -> HTTPStatus {
        return HTTPStatus.ok
    }

    func home(req: Request) async throws -> View {
        let context = BaseContext(
            title: "Home",
            description: "Home page")
        return try await req.render("index", context)
    }

    func login(req: Request) async throws -> View {
        let loginInfo = try req.query.decode(LoginInfo.self)
        let context = LoginContext(
            title: "Sign in",
            description: "Sign in",
            isLoginRequired: loginInfo.loginRequired,
            isLoginFailed: loginInfo.loginFailed,
            redirectUrl: loginInfo.redirectUrl
        )
        return try await req.render("auth/login", context)
    }

    func handleLogin (req: Request) async throws -> Response {
        if let path = try? req.query.get(String.self, at: "redirectUrl") {
            return req.redirect(to: path)
        } else {
            return req.redirect(to: "/")
        }
    }
    
    func handleLogout (req: Request) async throws -> Response {
        req.auth.logout(User.self)
        req.session.unauthenticate(User.self)
        return req.redirect(to: "/")
    }

    func register(req: Request) async throws -> View {
        let registerInfo = try req.query.decode(RegisterInfo.self)
        let context = RegisterContext(
            title: "Registration",
            description: "Create an account",
            userExists: registerInfo.userExists,
            userEmail: registerInfo.userEmail,
            passwordsMismatch: registerInfo.passwordsMismatch,
            redirectUrl: registerInfo.redirectUrl
        )
        return try await req.render("Auth/register", context)
    }
    
    func handleRegister(_ req: Request) async throws -> Response {
        //try RegisterRequest.validate(content: req)
        let registerRequest = try req.content.decode(RegisterRequest.self)
        guard registerRequest.password == registerRequest.confirmPassword else {
            req.logger.error(Logger.Message(stringLiteral: "Password doesn't match."))
            return req.redirect(to: "/register?passwordsMismatch=true")
        }
        
        let userCheck = try await User.query(on: req.db).filter(\.$email == registerRequest.email).first()
        guard userCheck == nil else {
            req.logger.error(Logger.Message(stringLiteral: "Email: \(registerRequest.email) already exists"))
            return req.redirect(to: "/register?userExists=true&userEmail=\(registerRequest.email)")
        }

        let hashedPassword = try await req.password.async.hash(registerRequest.password)
        let user = try User(from: registerRequest, hash: hashedPassword)
        try await user.save(on: req.db)
        return req.redirect(to: "/login")
    }
}
