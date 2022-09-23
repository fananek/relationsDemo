import Vapor

struct ProjectDTO: Content {
    let id: UUID?
    let title: String
    let users: [User]?
    
    init(id: UUID? = nil, title: String, users: [User]? = nil) {
        self.id = id
        self.title = title
        self.users = users
    }
    
    init(from project: Project) {
        self.init(id: project.id, title: project.title, users: project.$users.value)
    }
}
