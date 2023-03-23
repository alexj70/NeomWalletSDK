//
//  CollectibleInfoDataProvider.swift
//  NeomKit
//
//  Created by Aleksandr Zhovtyi on 23.11.2022.
//

import Foundation


public protocol CollectibleInfoDataProvider {
    func fetchInfo(tokenUri: String) async throws -> Endpoint.Collectible.Info?
}

struct CollectibleInfoEndpoint: EndpointProtocol {
    typealias Response = Endpoint.Collectible.Info
    typealias InputType = String
    var input: InputType
    
    var path: String { "/api/v1/nft/import" }
    var httpmethod: HttpUrlMethod { .POST }
    var bodyData: Data? { try? JSONEncoder().encode(input) }
}

extension NeomWalletSDK: CollectibleInfoDataProvider {
    public func fetchInfo(tokenUri: String) async throws -> Endpoint.Collectible.Info? {
//        let input = CollectibleInfoInput(tokenId: tokenId)
//        let endpoint = CollectibleInfoEndpoint(input: input)
//        return try await service.fetch(endpoint)
        
        let remote = "https://gateway.pinata.cloud/" + tokenUri.replacingOccurrences(of: "://", with: "/")
        guard let url = URL(string: remote) else {
            return nil
        }
        let session = URLSession.shared
        
        return try await withCheckedThrowingContinuation { continuation in
            let cancellable = session
                .dataTaskPublisher(for: url)
                .receive(on: DispatchQueue.main)
                .tryMap() { element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    
                    guard httpResponse.statusCode == 200 else {
                        let code = httpResponse.statusCode
                        switch code {
                        default:
                            let json = try? JSONSerialization.jsonObject(with: element.data, options: [])
                            let message = (json as? [String: Any])?["message"] as? String
                            debugPrint("👍 ", String(describing: type(of: self)),":", #function, " code ", code)
                            debugPrint("⚠️ ", String(describing: type(of: self)),":", #function, " ", json ?? "NO JSON" )
                            
                            let msg = message ?? (HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode) as Error).localizedDescription
                            let userInfo = [
                                NSLocalizedDescriptionKey: NSLocalizedString(msg, comment: "")
                            ]
                            throw NSError(domain: "", code: code, userInfo: userInfo)
                        }
                        
                    }
                    
                    if NeomWalletSDK.isDebugEnabled {
                        let json = try? JSONSerialization.jsonObject(with: element.data, options: [])
                        debugPrint("⚠️ ", String(describing: type(of: self)),":", #function, " ", json ?? "NO JSON" )
                    }
                    
                    
                    let decoder = JSONDecoder()
                    if let error = try? decoder.decode(ErrorResponse.self, from: element.data).error {
                        throw URLError(URLError.Code(rawValue: error.code), userInfo: error.userInfo)
                    }
                    
                    return element.data
                }
                .decode(type: Endpoint.Collectible.Info.self, decoder: JSONDecoder())
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .failure(let error):
                            debugPrint("🚫 ", String(describing: type(of: self)),":", #function, " ", error)
                            continuation.resume(with: .failure(error))
                        case .finished:
                            break
                        }
                        
                    },
                    receiveValue: { value in
                        continuation.resume(with: .success(value))
                    }
                )
            service.tokens?.append(cancellable)
            
        }
    }
}
