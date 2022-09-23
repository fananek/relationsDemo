import Vapor

func migrations(_ app: Application) throws {
    // Migrate models
    app.migrations.add(CreateUser())
    app.migrations.add(CreateProject())
    app.migrations.add(CreateUserProject())
}
