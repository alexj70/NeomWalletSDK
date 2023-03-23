//
//  ConfirmOperationDataProvider.swift
//  NeomKit
//
//  Created by Aleksandr Zhovtyi on 16.12.2022.
//

import Foundation

import Foundation

public protocol ConfirmOperationDataProvider {
    func confiirm(flowId value: String) async throws
}


struct ConfirmOperationEndpoint: EndpointProtocol {
    typealias Response = ConfirmOperationResult
    typealias InputType = ConfirmOperationInput
    var input: InputType
    
    var path: String { "/api/v1/auth/ConfirmOperation" }
    var httpmethod: HttpUrlMethod { .POST }
    var bodyData: Data? { try? JSONEncoder().encode(input) }
}


extension NeomWalletSDK: ConfirmOperationDataProvider {
    public func confiirm(flowId value: String) async throws {
        let input = ConfirmOperationInput(flowId: value)
        let endpoint = ConfirmOperationEndpoint(input: input)
        let result = try await service.fetch(endpoint)
        if !result.isSuccess {
            throw NSError.failedResult
        }
    }
}
