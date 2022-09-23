import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)

    app.views.use(.leaf)

    app.sessions.use(.fluent)
    app.migrations.add(SessionRecord.migration)

    app.sessions.configuration.cookieName = "relations-demo-app"           
    app.middleware.use(app.sessions.middleware)
    app.sessions.configuration.cookieFactory = { sessionID in
        .init(string: sessionID.string, isSecure: true)
    }
    app.middleware.use(User.sessionAuthenticator()) 

    // run migrations
    try migrations(app)
    if app.environment == .development {
        // seed development environment database
        try seeds(app)
    }

    // register routes
    try routes(app)
}
