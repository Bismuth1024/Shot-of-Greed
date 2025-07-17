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

struct DrinksPostRequest : Encodable {
    let name: String
    let description: String?
    let ingredients: [AlcoholicDrink.IngredientWrapper]
    let tags: [Tag]
    
    init(name: String, description: String?, ingredients: [AlcoholicDrink.IngredientWrapper], tags: [Tag]) {
        self.name = name
        self.description = description
        self.ingredients = ingredients
        self.tags = tags
    }
    
    init(_ drink: AlcoholicDrink) {
        self.name = drink.name
        self.description = drink.description
        self.ingredients = drink.ingredients
        self.tags = drink.tags
    }
}

struct IngredientQueryParams: URLQueryConvertible {
    var name: String?
    var minABV: Double?
    var maxABV: Double?
    var minSugar: Double?
    var maxSugar: Double?
    var minDate: Date?
    var maxDate: Date?
    var includeTagIDs: [Int]?
    var excludeTagIDs: [Int]?
    var requireAllTags: Bool?
    var includePublic: Bool?
    
    func asURLQueryItems() -> [URLQueryItem] {
        [
            .optional("name", name),
            .optional("min_ABV", minABV),
            .optional("max_ABV", maxABV),
            .optional("min_sugar", minSugar),
            .optional("max_sugar", maxSugar),
            .optional("min_date", minDate),
            .optional("max_date", maxDate),
            .optional("include_tag_ids", includeTagIDs),
            .optional("require_all_tags", requireAllTags),
            .optional("exclude_tag_ids", excludeTagIDs),
            .optional("include_public", includePublic)
        ].compactMap { $0 }
    }
}

struct DrinkQueryParams: URLQueryConvertible {
    var name: String? = nil
    var minStandards: Double? = nil
    var maxStandards: Double? = nil
    var minIngredients: Double? = nil
    var maxIngredients: Double? = nil
    var minSugar: Double? = nil
    var maxSugar: Double? = nil
    var minDate: Date? = nil
    var maxDate: Date? = nil
    var includeIngredientIDs: [Int]? = nil
    var excludeIngredientIDs: [Int]? = nil
    var requireAllIngredients: Bool? = nil
    var includeTagIDs: [Int]? = nil
    var excludeTagIDs: [Int]? = nil
    var requireAllTags: Bool? = nil
    var includePublic: Bool? = nil
    
    func asURLQueryItems() -> [URLQueryItem] {
        [
            .optional("name", name),
            .optional("min_standards", minStandards),
            .optional("max_standards", maxStandards),
            .optional("min_ingredients", minIngredients),
            .optional("max_ingredients", maxIngredients),
            .optional("min_sugar", minSugar),
            .optional("max_sugar", maxSugar),
            .optional("min_date", minDate),
            .optional("max_date", maxDate),
            .optional("include_ingredient_ids", includeIngredientIDs),
            .optional("require_all_ingredients", requireAllIngredients),
            .optional("exclude_ingredient_ids", excludeIngredientIDs),
            .optional("include_tag_ids", includeTagIDs),
            .optional("require_all_tags", requireAllTags),
            .optional("exclude_tag_ids", excludeTagIDs),
            .optional("include_public", includePublic)
        ].compactMap { $0 }
    }
}

struct SessionDrinksPostRequest: Encodable {
    let drink_id : Int
    let quantity: Int
    let start_time: Date
    let end_time: Date
    
    init(drink_id: Int, quantity: Int, start_time: Date, end_time: Date) {
        self.drink_id = drink_id
        self.quantity = quantity
        self.start_time = start_time
        self.end_time = end_time
    }
    
    init(from wrapper: DrinkingSession.SessionDrinkWrapper) {
        self.drink_id = wrapper.drink.id
        self.quantity = wrapper.quantity
        self.start_time = wrapper.startTime
        self.end_time = wrapper.endTime!
    }
}
