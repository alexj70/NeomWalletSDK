
struct DeleteAccountInput: Encodable {
    let newPassword: String = NeomUser.me.password
    let currentPassword: String = NeomUser.me.password
}
