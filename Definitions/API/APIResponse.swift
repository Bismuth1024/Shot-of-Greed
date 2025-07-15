//
//  APIResponse.swift
//  Fwaeh
//
//  Created by Manith Kha on 13/1/2025.
//

import Foundation

struct GenericError: Error, LocalizedError, Decodable {
    let message: String
    var errorDescription: String? {
        return message
    }
}

struct APIResponse<T: Decodable>: Decodable {
    let result: Result<T, GenericError>
    
    enum CodingKeys: CodingKey {
        case error_message
    }
    
    init(from decoder: Decoder) throws {
        // Try decoding error response first
        if let error = try? GenericError(from: decoder) {
            self.result = .failure(error)
        } else {
            let value = try T(from: decoder)
            self.result = .success(value)
        }
    }
}

struct APIError : Error, Decodable {
    let message : String
}

struct NewUserIDResponse : Decodable {
    let new_user_id : Int
}

struct NewIngredientIDResponse : Decodable {
    let new_ingredient_id : Int
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
