import Fluent
import Vapor

final class Project: Model, Content {
    static let schema = "projects"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Siblings(through: UserProject.self, from: \.$project, to: \.$user)
    public var users: [User]

    init() { }

    init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
    }
}
