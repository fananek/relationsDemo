import Fluent

struct CreateUserProject: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("user+project")
            .id()
            .field("user_id", .uuid, .required)
            .field("project_id", .uuid, .required)
            .foreignKey("user_id", references: "users", "id", onDelete: .cascade)
            .foreignKey("project_id", references: "projects", "id", onDelete: .cascade)
            .unique(on: "user_id", "project_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("user+project").delete()
    }
}
