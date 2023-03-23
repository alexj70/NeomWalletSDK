
public protocol FetchCollectiblesDataProvider {
    func fetchCollectibleList() async throws -> [Endpoint.Collectible]
}


struct FetchCollectiblesEndpoint: EndpointProtocol {
    typealias Response = [Endpoint.Collectible]
    typealias InputType = Void
    var input: InputType = Void()
    
    var path: String { "/api/v1/nft" }
    var httpmethod: HttpUrlMethod { .GET }
}


extension NeomWalletSDK: FetchCollectiblesDataProvider {
    public func fetchCollectibleList() async throws -> [Endpoint.Collectible] {
        let endpoint = FetchCollectiblesEndpoint()
        let value = try await service.fetch(endpoint)
        
//#if DEBUG
//        if value.isEmpty {
//            return [
//                Endpoint.Collectible(uid: 1, tokenId: 12, tokenURI: URL(string: "https://demo-res.cloudinary.com/image/upload/sample.jpg")!),
//                Endpoint.Collectible(uid: 2, tokenId: 22, tokenURI: URL(string: "https://www.reasoft.com/tutorials/web/img/progress.jpg")!),
//                Endpoint.Collectible(uid: 3, tokenId: 32, tokenURI: URL(string: "https://live.staticflickr.com/65535/52486519600_8539f27aa1_b.jpg")!),
//                Endpoint.Collectible(uid: 4, tokenId: 42, tokenURI: URL(string: "https://live.staticflickr.com/8525/8581057667_0de30eb752_h.jpg")!),
//                Endpoint.Collectible(uid: 5, tokenId: 52, tokenURI: URL(string: "https://live.staticflickr.com/8525/8581057667_0de30eb752_h.jpg")!),
//                Endpoint.Collectible(uid: 6, tokenId: 62, tokenURI: URL(string: "https://live.staticflickr.com/65535/52464479268_e97e5f6a4f_h.jpg")!),
//                Endpoint.Collectible(uid: 7, tokenId: 72, tokenURI: URL(string: "https://live.staticflickr.com/65535/52479576442_790888b824_h.jpg")!),
//                Endpoint.Collectible(uid: 8, tokenId: 82, tokenURI: URL(string: "https://live.staticflickr.com/65535/52402437371_16b3b544bc_h.jpg")!),
//                Endpoint.Collectible(uid: 9, tokenId: 92, tokenURI: URL(string: "https://live.staticflickr.com/65535/52396638994_65d0a1e012_h.jpg")!),
//                Endpoint.Collectible(uid: 10, tokenId: 102, tokenURI: URL(string: "https://live.staticflickr.com/5582/14596767597_924e4788be_h.jpg")!),
//            ]
//        } else {
//            return value
//        }
//
//
//#else
        return value
//#endif
//
    }
}
