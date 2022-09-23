import Vapor

extension Request {
    func render<Context: Encodable>(_ template: String, _ context: Context) async throws -> View {
        let webpageURL = self.url.path
        let now = Date()

        var userDTO: UserDTO?
        if let user = self.auth.get(User.self) {
            userDTO = UserDTO(from: user)
        }
        
        let pageInfo = PageInfo(
            pageData: context,
            loggedInUser: userDTO,
            webpageURL: webpageURL,
            now: now
        )
        return try await self.view.render(template, pageInfo)
    }
}
