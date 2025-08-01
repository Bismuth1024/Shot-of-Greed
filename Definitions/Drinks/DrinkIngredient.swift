//
//  DrinkIngredient.swift
//  Fwaeh
//
//  Created by Manith Kha on 8/2/2023.
//

import Foundation

/*
 A model for representing an ingredient of a drink.
 
 
 Properties:
    name: Name
    ABV:
    sugarPercent: (g/100 mL)
    tags: things like spirit, alcohol free, etc. could be used for later
 
 The static constants contain some default common ingredients, such as:
 Vodka: "Vodka", 40% alcohol, 0% sugar, tagged with spirit and sugar free
 
 In this application, ingredients need to be uniquely identified by their name - So you cannot have two
 different vodkas in one drink for example, one of them needs to be renamed.
 
 Note the distinction between the static constant Vodka and the name "Vodka" - an ingredient could be added with the name "Vodka",
 but with different other values to the static constant Vodka.  The static constants are for convenience, and eventually will be added
 to by the user: for example, they could add in "Vodka (brand X)" with 45 ABV if it's something they use often.
 
 This file also contains some volumes such as shot (corresponding to 30 mL) and so on.  The static constants can be retrieved by their
 name via the DrinkIngredient.IngredientDictionary variable.
 
 See more discussion in the AlcoholicDrink file.
 */

struct DrinkIngredient : Hashable, Equatable, Codable, Identifiable, Taggable
{
    var id: Int = 0
    var created_user_id : Int = 1
    var create_time = Date()
    var description: String? = nil
    var name: String = ""
    var ABV: Double = 0
    var sugarPercent: Double = 0
    var tags: [Tag] = []
    
    init(id: Int = 0, created_user_id: Int = 1, create_time: Date = Date(), description: String? = nil, name: String = "", ABV: Double = 0, sugarPercent: Double = 0, tags: [Tag] = []) {
        self.id = id
        self.created_user_id = created_user_id
        self.create_time = create_time
        self.description = description
        self.name = name
        self.ABV = ABV
        self.sugarPercent = sugarPercent
        self.tags = tags
    }
    
    init() {}
        
    static func == (lhs: DrinkIngredient, rhs: DrinkIngredient) -> Bool {
        return lhs.name == rhs.name && lhs.ABV == rhs.ABV && lhs.sugarPercent == rhs.sugarPercent && lhs.tags == rhs.tags
    }
    
    static let Sizes = [
        "1/4 oz",
        "1/3 oz",
        "1/2 oz",
        "2/3 oz",
        "3/4 oz",
        "1 oz",
        "1 1/4 oz",
        "1 1/3 oz",
        "1 1/2 oz",
        "1 2/3 oz",
        "1 3/4 oz",
        "2 oz",
        "3 oz",
        "4 oz",
        
        "Shot",
        "Shooter",
        "Small wine glass",
        "Medium wine glass",
        "Large wine glass",
        "Beer bottle",
        "Can"
    ]
    
    static let Volumes = [
        7.5,
        10,
        15,
        20,
        22.5,
        30,
        37.5,
        40,
        45,
        50,
        52.5,
        60,
        90,
        120,
        
        30,
        60,
        150,
        200,
        250,
        375,
        330
    ]
    
    static var SizesDictionary = Dictionary(uniqueKeysWithValues: zip(Sizes, Volumes))
    
    static var IngredientsDictionary : [Int : DrinkIngredient] = [:]
    
    static var ABVOptions : [Double] = (0...200).map{Double($0)/2}
    
    static var Sample = DrinkIngredient(id: 0, name: "Jagermeister", ABV: 35, sugarPercent: 13.2, tags: [])
    
    /*
    static func loadCustomIngredients() {
        let customIngredients: [DrinkIngredient]? = Settings.loadCodable(key: "customIngredients")
        
        if let customIngredients {
            for ingredient in customIngredients {
                IngredientsDictionary[ingredient.name] = ingredient
            }
        }
    }
     */
}
