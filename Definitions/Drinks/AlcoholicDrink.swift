//
//  AlcoholicDrink.swift
//  Fwaeh
//
//  Created by Manith Kha on 16/10/2023.
//

/*
 A model representing an alcoholic drink.
 
 id: For identifiable, may not be needed, currently its via name as well.
 name:
 imageName: For what to display as an icon
 ingredients: of type IngredientWrapper
 
 IngredientWrapper is just a DrinkIngredient and volume (Double) but as a struct so it can conform to protocols
 
 Ingredients can be added and removed via their name (String), adding by name will take from DrinkIngredient.IngredientsDictionary
 
 Just like for DrinkIngredient, there are a bunch of static constants for convenience that are again uniquely identified by name.
 
 
 
 */

import Foundation


struct AlcoholicDrink : Identifiable, Equatable, Codable, Hashable, Taggable {
    var id : Int
    var name: String
    var created_user_id : Int = 1
    var create_time = Date()
    var description: String? = nil
    var ingredients: [IngredientWrapper]
    var tags: [Tag] = []
    
    init(id: Int, name: String, ingredients: [(DrinkIngredient, Double)], tags: [Tag] = []) {
        self.id = id
        self.name = name
        self.ingredients = []
        for ingredient in ingredients {
            self.ingredients.append(IngredientWrapper(ingredientType: ingredient.0, volume: ingredient.1))
        }
        self.tags = tags
    }

    static func == (lhs: AlcoholicDrink, rhs: AlcoholicDrink) -> Bool {
        if lhs.name != rhs.name {
            return false
        }
        
        if lhs.ingredients.count != rhs.ingredients.count {
            return false
        }
        
        for idx in lhs.ingredients.indices {
            if (lhs.ingredients[idx] != rhs.ingredients[idx]) {
                return false
            }
        }
        
        if lhs.tags != rhs.tags {
            return false
        }
        return true
    }
    
    func numIngredients() -> Int {
        return ingredients.count
    }
    
    func numStandards() -> Double {
        var toReturn = 0.0
        for ingredient in ingredients {
            toReturn += ingredient.numStandards()
        }
        return toReturn
    }
    
    func totalSugar() -> Double {
        var toReturn = 0.0
        for ingredient in ingredients {
            toReturn += (ingredient.ingredientType.sugarPercent/100) * ingredient.volume
        }
        return toReturn
    }
    
    func totalVolume() -> Double {
        return ingredients.reduce(0.0, {current, wrapper in
            current + wrapper.volume
        })
    }
    
    @discardableResult mutating func addIngredient(id: Int, volume: Double) -> Bool {
        if let ingredient = DrinkIngredient.IngredientsDictionary[id] {
            ingredients.append(IngredientWrapper(ingredientType: ingredient, volume: volume))
            return true
        } else {
            return false
        }
    }

    @discardableResult mutating func addIngredient() -> Bool {
        return addIngredient(id: 1, volume: 30)
    }

    @discardableResult mutating func removeIngredient(id: Int) -> Bool {
        let index = ingredients.firstIndex(where: {$0.ingredientType.id == id})
        if let index {
            ingredients.remove(at: index)
            return true
        } else {
            return false
        }
    }
    
    func printInfo() {
        print("Drink \"\(name)\" contains \(ingredients.count) ingredients:\n")
        for ingredient in ingredients {
            print(ingredient.info())
        }
    }
    
    func containsIngredient(id: Int) -> Bool {
        return ingredients.contains(where: {$0.ingredientType.id == id})
    }
    
    func isValid() -> Bool {
        return !(containsIngredient(id: 1) || ingredients.count == 0)
    }
    
    struct IngredientWrapper: Hashable, Identifiable, Codable, Equatable {
        //Needed for plotting - Don't just use tuple
        var ingredientType: DrinkIngredient
        var volume: Double
        
        var id : Int {
            ingredientType.id
        }
        
        static func == (lhs: IngredientWrapper, rhs: IngredientWrapper) -> Bool {
            (lhs.ingredientType == rhs.ingredientType) && (lhs.volume == rhs.volume)
        }
        
        func numStandards() -> Double {
            (ingredientType.ABV/100) * volume * 0.078
        }
        
        func info() -> String {
            return ("\(ingredientType.name), \(volume) mL, \(ingredientType.ABV)% Alcohol, \(ingredientType.sugarPercent)% sugar\n")
        }
    }
    
    enum DrinkingMethod {
        case chug, slow
    }
    
    static var DrinkDictionary : [String : AlcoholicDrink] = [:]
    
    static var DrinkNames: [String] {
        Array(DrinkDictionary.keys).sorted()
    }
    
    static var Sample = AlcoholicDrink(id: 1, name: "Sample Drink", ingredients: [(DrinkIngredient.Sample, 100)])
}

struct AlcoholicDrinkOverview : Codable, Hashable, Identifiable {
    var id: Int
    var name: String
    var created_user_id: Int
    var create_time: Date
    var n_ingredients: Int
    var n_standards: Double
    var sugar_g: Double
    
    init(id: Int, name: String, created_user_id: Int, create_time: Date, n_ingredients: Int, n_standards: Double, sugar_g: Double) {
        self.id = id
        self.name = name
        self.created_user_id = created_user_id
        self.create_time = create_time
        self.n_ingredients = n_ingredients
        self.n_standards = n_standards
        self.sugar_g = sugar_g
    }
    
    init(drink: AlcoholicDrink) {
        self.id = drink.id
        self.name = drink.name
        self.created_user_id = drink.created_user_id
        self.create_time = drink.create_time
        self.n_ingredients = drink.numIngredients()
        self.n_standards = drink.numStandards()
        self.sugar_g = drink.totalSugar()
    }
}

/*
 drink_id
 - name
 - created_user_id
 - create_time
 - n_ingredients
 - n_standards
 - sugar_g
 */

