import Foundation

extension Endpoint.Collectible {
    public struct Info: Decodable {
        public let title: String?
        public let description: String?
        public let category: String?
        let image: String?
        
        public var picture: URL? {
            debugPrint("👍 ", String(describing: type(of: self)),":", #function, " image ", image)
            guard let image else { return nil }
            let path = image.replacingOccurrences(of: "ipfs://", with: "").replacingOccurrences(of: " ", with: "%20")
            
            
            debugPrint("👍 ", String(describing: type(of: self)),":", #function, " path ", path)
            let fullPath = "https://gateway.pinata.cloud/ipfs/\(path)"
            debugPrint("👍 ", String(describing: type(of: self)),":", #function, " fullPath ", fullPath)
            let url = URL(string: fullPath)

            debugPrint("👍 ", String(describing: type(of: self)),":", #function, " url ", url)
            return url
        }
        
    }
}
