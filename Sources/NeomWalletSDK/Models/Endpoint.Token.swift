
extension Endpoint {
    public struct Token: Decodable {
        public let balance: Double
        public let convertedBalance: Double?
        public let cryptoCurrency: String
        public let contract: Endpoint.Contract?
        public let exchangeRate: Double?
    }
}
