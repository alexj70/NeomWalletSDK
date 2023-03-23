struct LoginResult: Decodable {
    struct user: Decodable {
        let id: String
        let email: String
        let fullName: String
        let phoneNumber: String
    }
    
    
    let token: String
    let user: LoginResult.user
    
}
