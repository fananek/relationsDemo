import Fluent
import Vapor

final class UserProject: Model, Content {
    static let schema = "user+project"
    
    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "project_id")
    var project: Project
		
    init() {}
    
    init(id: UUID? = nil, user: User, project: Project) throws {
        self.id = id
        self.$user.id = try user.requireID()
        self.$project.id = try project.requireID()
    }
}
