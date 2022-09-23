import Vapor

struct UserDTO: Content {
    let id: UUID?
    let fullName: String
    let email: String
    let projects: [Project]?
    
    init(id: UUID? = nil, fullName: String, email: String, projects: [Project]? = nil) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.projects = projects
    }
    
    init(from user: User) {
        self.init(id: user.id, fullName: user.fullName, email: user.email, projects: user.$projects.value)
    }
}
