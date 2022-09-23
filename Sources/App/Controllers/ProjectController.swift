import Fluent
import Vapor

struct ProjectController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let projects = routes.grouped("projects")
        projects.get(use: renderIndex)
        projects.post(use: create)
        projects.group(":projectID") { project in
            project.get(use: getByID)
            project.delete(use: delete)
            project.get("assign", ":userID", use: assignUser)
            project.get("remove", ":userID", use: removeUser)
        }
    }

    func index(req: Request) async throws -> [Project] {
        try await Project.query(on: req.db).all()
    }

     func renderIndex(req: Request) async throws -> View {
        let projects = try await Project.query(on: req.db).with(\.$users)
        .all().map { project in
            ProjectDTO(from: project)
        }
        let context = ProjectsContext(
            title: "Projects", 
            description: "Projects", 
            projects: projects)
        return try await req.render("projects/projectsIndex", context)
    }

    func getByID(req: Request) async throws -> ProjectDTO {
        guard let project = try await Project.find(req.parameters.get("projectID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return ProjectDTO(from: project)
    }

    func create(req: Request) async throws -> Project {
        let project = try req.content.decode(Project.self)
        try await project.save(on: req.db)
        return project
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let project = try await Project.find(req.parameters.get("projectID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await project.delete(on: req.db)
        return .noContent
    }

    func assignUser(req: Request) async throws -> Response {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let project = try await Project.find(req.parameters.get("projectID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await project.$users.attach(user, method: .ifNotExists, on: req.db)
        return req.redirect(to: "/projects")
    }

    func removeUser(req: Request) async throws -> Response {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let project = try await Project.find(req.parameters.get("projectID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await project.$users.detach(user, on: req.db)
        return req.redirect(to: "/projects")
    }
}
