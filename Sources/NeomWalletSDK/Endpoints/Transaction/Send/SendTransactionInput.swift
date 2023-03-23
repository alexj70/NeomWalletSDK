public struct SendTransactionInput: Encodable {
    public let txId: String
    public let receiverAddress: String
    public let amount: String
    @NullEncodable public var contract: String?
    
    public init(txId: String, receiverAddress: String, amount: String, contract: String?) {
        self.txId = txId
        self.receiverAddress = receiverAddress
        self.amount = amount
        self.contract = contract
    }
}

