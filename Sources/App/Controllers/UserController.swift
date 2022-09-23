import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: renderIndex)
        users.post(use: create)
        users.group(":userID") { user in
            user.get(use: getByID)
            user.delete(use: delete)
        }
    }

    func index(req: Request) async throws -> [User] {
        try await User.query(on: req.db).all()
    }

    func renderIndex(req: Request) async throws -> View {
        let users = try await User.query(on: req.db).with(\.$projects)
        .all().map { user in
            UserDTO(from: user)
        }
        let context = UsersContext(
            title: "Users", 
            description: "Users", 
            users: users)
        return try await req.render("users/usersIndex", context)
    }

    func getByID(req: Request) async throws -> UserDTO {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return UserDTO(from: user)
    }

    func profile(req: Request) async throws -> View {
        guard let id: UUID = req.parameters.get("userID") else {
            throw Abort(.badRequest)
        }
        guard let user = try await User.query(on: req.db).filter(\.$id == id).with(\.$projects).first() else {
            throw Abort(.notFound)
        }
        let userDTO = UserDTO(from: user)

        let context = UserProfileContext(
            title: "My profile", 
            description: "My profile", 
            user: userDTO)
        return try await req.render("users/profile", context)
    }

    func create(req: Request) async throws -> User {
        let user = try req.content.decode(User.self)
        try await user.save(on: req.db)
        return user
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await user.delete(on: req.db)
        return .noContent
    }
}
