struct ChangePasswordInput: Encodable {
    let newPassword: String
    let currentPassword: String = NeomUser.me.password
    
    
}
