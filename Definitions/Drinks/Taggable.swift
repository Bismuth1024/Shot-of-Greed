//
//  Taggable.swift
//  Fwaeh
//
//  Created by Manith Kha on 23/1/2024.
//

import Foundation

struct Tag : Identifiable, Equatable, Codable, Hashable {
    let id: Int
    let name: String
    let type: String?
    
    static var LoadedTags: [Tag] = []
}

protocol Taggable {
    var tags: [Tag] {get set}
    @discardableResult mutating func addTag(_ tag: Tag) -> Bool
    @discardableResult mutating func removeTag(_ tag: Tag) -> Bool
    func hasTag(_ tag: Tag) -> Bool
}

extension Taggable {
    mutating func addTag(_ tag: Tag) -> Bool {
        if !tags.contains(tag) {
            tags.append(tag)
            return true
        } else {
            return false
        }
    }
    
    mutating func removeTag(_ tag: Tag) -> Bool {
        tags.removeAll { $0 == tag }
        return true
    }
    
    func hasTag(_ tag: Tag) -> Bool {
        return tags.contains(tag)
    }
}
