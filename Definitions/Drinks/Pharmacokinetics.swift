//
//  Pharmacokinetics.swift
//  Yesh
//
//  Created by Manith Kha on 18/1/2024.
//

import Foundation

struct Pharmacokinetics {
    static func calculateTBW(sex: String, age: Double, height: Double, mass: Double) -> Double {//cm, kg -> L
        if sex == "male" {
            return 2.447 - 0.09516*age + 0.1074*height + 0.3362*mass
        } else if sex == "female" {
            return -2.097 + 0.1069*height + 0.2446*mass
        }
        //how did we get here
        return -696969
    }
    
    static func calcuateVd(sex: String, age: Double, height: Double, mass: Double) -> Double {//cm, kg)
        let TBW = calculateTBW(sex: sex, age: age, height: height, mass: mass)
        
        var waterInBlood: Double = 0.0
        
        if sex == "male" {
            waterInBlood = 0.825
        } else if sex == "female" {
            waterInBlood = 0.838
        }
        
        return (TBW/mass)/waterInBlood
    }
    
}
