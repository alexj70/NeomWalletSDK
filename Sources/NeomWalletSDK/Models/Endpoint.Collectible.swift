extension Endpoint {
    public struct Collectible: Decodable {
        public let owner: String?
        public let tokenId: Int64
        public let tokenURI: String
        
        init(owner: String, tokenId: Int64, tokenURI: String) {
            self.owner = owner
            self.tokenId = tokenId
            self.tokenURI = tokenURI
        }
    }
}
