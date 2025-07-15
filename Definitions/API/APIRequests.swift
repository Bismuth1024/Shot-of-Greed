//
//  APIRequests.swift
//  Shot of Greed
//
//  Created by Manith Kha on 15/7/2025.
//

import Foundation

struct UsersPostRequest : Encodable {
    let username: String
    let password: String
    let email: String?
    let birthdate: String
    let gender: String

    init(username: String, password: String, email: String?, birthdate: Date, gender: String) {
        self.username = username
        self.password = password
        self.email = email
        self.birthdate = DateHelpers.SQLDateFormatter.string(from: birthdate)
        self.gender = gender
    }
}

struct LoginPostRequest : Encodable {
    let username: String
    let password: String
}

struct IngredientsPostRequest : Encodable {
    let name: String
    let ABV: Double
    let sugarPercent: Double
    let description: String?
    let tags: [Tag]
    
    init(name: String, ABV: Double, sugarPercent: Double, description: String? = nil, tags: [Tag] = []) {
        self.name = name
        self.ABV = ABV
        self.sugarPercent = sugarPercent
        self.description = description
        self.tags = tags
    }
    
    init(_ ingredient: DrinkIngredient) {
        self.name = ingredient.name
        self.ABV = ingredient.ABV
        self.sugarPercent = ingredient.sugarPercent
        self.description = ingredient.description
        self.tags = ingredient.tags
    }
}
