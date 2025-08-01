//
//  TagsManager.swift
//  Shot of Greed
//
//  Created by Manith Kha on 22/7/2025.
//

import Foundation

class TagsManager {
    var AllTags: [Tag] = []
    
    func loadTags() {
        API.getTags(using: TagsQueryParams()) { result in
            switch result {
            case .failure(let error):
                fatalError(String(describing: error))
            case .success(let tags):
                self.AllTags = tags
            }
        }
    }
    
    var DrinkTags: [Tag] {
        AllTags.filter{$0.type == "Drink"}
    }
    
    var IngredientTags: [Tag] {
        AllTags.filter{$0.type == "Ingredient"}
    }
}
