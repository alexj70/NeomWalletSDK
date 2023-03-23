 public protocol PersonalInfo {
    var fullName: String? { get set }
    var email: String? { get set }
    var phone: String? { get set }
}

 extension PersonalInfo {
    public var isEmpty: Bool {
        fullName == nil || email == nil || phone == nil
    }
}
