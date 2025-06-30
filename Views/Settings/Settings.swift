//
//  Settings.swift
//  Yesh
//
//  Created by Manith Kha on 13/1/2024.
//

import Foundation

struct Settings {
    static let Storage = UserDefaults.standard
    
    static func convertToRaw<T: Codable>(_ input: T) -> Data {
        var data: Data
        do {
            data = try JSONEncoder().encode(input)
        } catch {
            fatalError(String(describing: error))
        }
        
        return data
    }
    
    static func convertFromRaw<T: Codable>(_ input: Data) -> T {
        var toReturn: T
        do {
            toReturn = try JSONDecoder().decode(T.self, from: input)
        } catch {
            fatalError(String(describing: error))
        }
        
        return toReturn
    }
    
    static func saveArray<T: Codable>(_ arr: [T], key: String) {
        let codedArray: [Data] = arr.map({convertToRaw($0)})
        Storage.set(codedArray, forKey: key)
    }
    
    static func loadArray<T: Codable>(key: String) -> [T]? {
        if let out = Storage.array(forKey: key) as? [Data] {
            let toReturn: [T] = out.map({convertFromRaw($0)})
            return toReturn
        } else {
            return nil
        }
    }
    
    static func saveCodable<T: Codable>(_ object: T, key: String) {
        let data = convertToRaw(object)
        Storage.set(data, forKey: key)
    }
    
    static func loadCodable<T: Codable>(key: String) -> T? {
        if let data = Storage.data(forKey: key) {
            return convertFromRaw(data)
        } else {
            return nil
        }
    }
    
    static let Defaults: Dictionary<String, Any> = [
        "bodyMass": 70.0,
        "massUnits": "kg",
        "age": 21.0,
        "sex": "male",
        "height": 170.0,
        "vd": Pharmacokinetics.calcuateVd(sex:"male", age: 21, height: 170, mass: 70),
        "vdManual": false,
        "t_step": 60.0,
        "k_stomach": 0.005,
        "k_blood": 0.0005,
        "m_blood": 0.02/3600,
        "BACextrapolationTarget": 0.05,
        "customIngredients": [DrinkIngredient](),
        "customDrinks": [AlcoholicDrink](),
       // "allTimeRecords": StatRecords()

        
        
        
    ]
    
    static let keys: Dictionary<String, Any.Type> = [
        "Body": Double.self,
        "Test": Int.self
    ]
    
    
    static let validKeys = Defaults.keys
    
    /*
    [
        "bodyMass", //Double body mass in units below
        "massUnits", //units for mass: kg or lbs
        "t_step", //Time step in seconds
        "k_stomach",
        "k_blood",
        "m_blood",
        "customIngredients", // [DrinkIngredient]
        "customDrinks", //[AlcoholicDrink]
        "", //
        "", //
        "", //
        "", //
        "", //
        "", //
        "", //
        "", //
        "", //
        "", //
        "", //
        "" //

    ]
     */
    
    enum Sex : String, RawRepresentable, CaseIterable {
        case male = "male"
        case female = "female"
    }
    
    enum MassUnits : RawRepresentable, CaseIterable {
        typealias RawValue = (String, Double)
        
        init?(rawValue: RawValue) {
            switch rawValue {
            case ("kg", 1):
                self = .kg
            case ("lb", 0.454):
                self = .lb
            default:
                return nil
            }
        }
        
        var rawValue: RawValue {
            switch self {
            case .kg: return ("kg", 1)
            case .lb: return ("lb", 0.454)
            }
        }
        
        case kg, lb
    }
    
}
