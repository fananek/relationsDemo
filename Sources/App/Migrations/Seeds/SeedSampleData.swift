import Vapor
import Fluent

// DON'T USE ON PRODUCTION!!
struct SeedSampleData: AsyncMigration {
    func prepare(on database: Database) async throws {
        // Seed default users
        let password = try? Bcrypt.hash("password")
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }

        let user1: User = .init(fullName: "User 1", email: "user1@acme.com", passwordHash: hashedPassword) 
        try await user1.save(on: database)

        let user2: User = .init(fullName: "User 2", email: "user2@acme.com", passwordHash: hashedPassword) 
        try await user2.save(on: database)

        // Seed projects
        let alpha: Project = .init(title: "Project Alpha") 
        try await alpha.save(on: database)

        let beta: Project = .init(title: "Project Beta") 
        try await beta.save(on: database)

        let gamma: Project = .init(title: "Project Gamma") 
        try await gamma.save(on: database)

        // Assign users to projects
        try await user1.$projects.attach(alpha, on: database)
        try await user1.$projects.attach(beta, on: database)

        // you can also do it from the other way
        try await beta.$users.attach(user2, on: database)
        try await gamma.$users.attach(user2, on: database)
    }

    func revert(on database: Database) async throws {
        try await User.query(on: database).delete()
        try await Project.query(on: database).delete()
        // pivot records will be deleted automatically becasue of .cascade deletion defined in migration
    }
}
