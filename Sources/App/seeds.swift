import Vapor

func seeds(_ app: Application) throws {
    // Seed database
    app.migrations.add(SeedSampleData())
}
