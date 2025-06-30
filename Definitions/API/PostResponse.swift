//
//  CreateResponse.swift
//  Fwaeh
//
//  Created by Manith Kha on 9/1/2025.
//


import Foundation

enum PostResponse<T>: Decodable where T : Decodable {
    case success(id: T)
    case failure(error: String)
    
    // Custom decoding logic
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Try decoding the ID as an Int
        if let id = try? container.decode(T.self) {
            self = .success(id: id)
            return
        }
        
        // Otherwise, decode the error message as a String
        if let error = try? container.decode(String.self) {
            self = .failure(error: error)
            return
        }
        
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unexpected JSON structure")
    }
}

struct GenericError: Error, LocalizedError {
    let message: String
    var errorDescription: String? {
        return message
    }
}

enum PostResponseError: Error, LocalizedError {
    case missingID(String)
    case unexpectedResponse

    var errorDescription: String? {
        switch self {
        case .missingID(let message):
            return "Failed to retrieve the ID: \(message)"
        case .unexpectedResponse:
            return "The server returned an unexpected response."
        }
    }
}
