//
//  APIResponse.swift
//  Fwaeh
//
//  Created by Manith Kha on 13/1/2025.
//

import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let result: Result<T, GenericError>
    
    enum CodingKeys: CodingKey {
        case error_message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let message = try? container.decode(String.self, forKey: .error_message) {
            // If "message" exists, it's an error
            result = .failure(GenericError(message: message))
        } else {
            // Try decoding the success value
            let value = try T(from: decoder)
            result = .success(value)
        }
    }
}

struct APIError : Error, Decodable {
    let message : String
}

struct NewIDResponse : Decodable {
    let new_user_id : Int
}

struct LoginResponse : Decodable {
    let user_id : Int
    let login_token : String
    let expiry : Date
}

struct TagsResponse : Decodable {
    let tags : [Tag]
}

struct IngredientsResponse: Decodable {
    var ingredients: [DrinkIngredient]

}
