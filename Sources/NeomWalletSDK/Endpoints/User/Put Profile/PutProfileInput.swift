import Foundation

struct PutProfileInput: Encodable {
    let fullName: String
    let phoneNumber: String
    let email: String
    
    init(info: PersonalInfo) {
        self.phoneNumber = info.phone ?? ""
        self.email = info.email ?? ""
        self.fullName = info.fullName ?? ""
    }
}
