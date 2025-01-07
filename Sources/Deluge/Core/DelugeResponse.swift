//
//  DelugeResponse.swift
//  Deluge
//
//  Created by ninji on 02/01/2025.
//

public struct DelugeResponse<Value: Decodable>: Decodable {
    let id: Int
    let result: Value
    let error: Error?

    struct Error: Decodable {
        let message: String
        let code: Int
    }
}
