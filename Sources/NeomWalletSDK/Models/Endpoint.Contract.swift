
extension Endpoint {
    public struct Contract: Decodable {
        public let name: String
        public let symbol: String
        public let address: String
        public let decimals: Int
        public let logoUrl: String
    }
    
}

