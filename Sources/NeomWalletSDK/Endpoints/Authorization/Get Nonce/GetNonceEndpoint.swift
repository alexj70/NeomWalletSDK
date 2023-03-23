//
//  GetNonceEndpoint.swift
//  NeomKit
//
//  Created by Aleksandr Zhovtyi on 20.10.2022.
//

import Foundation

public protocol GetNonceDataProvider {
    func fetchRestoreNonce(ethPublicKey: String) async throws -> Int
}


struct GetNonceEndpoint: EndpointProtocol {
    typealias Response = GetNonceResult
    typealias InputType = GetNonceInput
    var input: InputType
    
    
    var path: String { "/api/v1/auth/forgotPassword"}
    var parameters: [String: String]? {
        [
            "ethPublicKey": input.ethPublicKey
        ]
    }
    var isAuthorized: Bool { false }
    var httpmethod: HttpUrlMethod { .GET }
    
}

extension NeomWalletSDK: GetNonceDataProvider {
    public func fetchRestoreNonce(ethPublicKey: String)  async throws -> Int {
        let endpoint = GetNonceEndpoint(input: GetNonceInput(ethPublicKey: ethPublicKey))
        let value = try await service.fetch(endpoint)
        return value.nonce
    }
}
