extension Endpoint {
    public struct TokenInfo: Decodable {
        public let name: String
        public let symbol: String
        public let adress: String
        public let decimal: Int16
    }
}
