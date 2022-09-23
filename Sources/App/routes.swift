import Vapor

func routes(_ app: Application) throws {
    let controllers: [RouteCollection] = [
        BaseController(),
        UserController(),
        ProjectController()        
        ]
    for controller in controllers {
        try app.register(collection: controller)
    }
}
