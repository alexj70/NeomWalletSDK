import Foundation
extension Endpoint {
    public struct Transaction: Decodable {
        public let txId: String
        public let transactionHash: String
        @DateDecodable public var createdAt: Date
        @DateDecodable public var confirmed: Date
        //          let status: Failed
        //          let type: Receive
        public let total: Double
        public let convertedTotal: Double
        public let fee: Double
        public let convertedFee: Double
        public let cryptoCurrency: String
        public let contract: Contract?
    }
}

