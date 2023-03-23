import Foundation

extension String: Error {}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

extension Error {
    public var code: Int {
        let nserror = self as NSError
        return nserror.code
    }
}
