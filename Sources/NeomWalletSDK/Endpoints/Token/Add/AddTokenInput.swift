
public struct AddTokenInput: Encodable {
    let address: String
    let cryptoCurrency: String
    
    public init(address: String, cryptoCurrency: String) {
        self.address = address.lowercased()
        self.cryptoCurrency = cryptoCurrency.uppercased()
    }
}

