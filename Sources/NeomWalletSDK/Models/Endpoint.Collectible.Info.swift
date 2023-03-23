import Foundation

extension Endpoint.Collectible {
    public struct Info: Decodable {
        public let title: String?
        public let description: String?
        public let category: String?
        let image: String?
        
        public var picture: URL? {
            guard let image else { return nil }
            let path = image.replacingOccurrences(of: "ipfs://", with: "").replacingOccurrences(of: " ", with: "%20")
            let fullPath = "https://gateway.pinata.cloud/ipfs/\(path)"
            let url = URL(string: fullPath)
            return url
        }
        
    }
}
