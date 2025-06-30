//
//  Helpers.swift
//  Yesh
//
//  Created by Manith Kha on 3/1/2024.
//

import Foundation

func ceilingMultiple(value: Double, quotient: Double) -> Double {
    return floorMultiple(value: value, quotient: quotient) + quotient
}

func floorMultiple(value: Double, quotient: Double) -> Double {
    return value - (value.truncatingRemainder(dividingBy: quotient))
}

func printArray(_ arr: Array<Any>) {
    for idx in arr.indices {
        print("Index \(idx): \(arr[idx])")
    }
}

func generateTicks(from lower: Double, through upper: Double, targetCount: Int, tickSpacings: [Double]) -> [Double] {
    var minDiff = Double.greatestFiniteMagnitude
    var toUse = 0.0
    
    for spacing in tickSpacings {
        let nTicks = Double(floor((upper - lower)/spacing)) + 1
        let diff = abs(nTicks - Double(targetCount))
    
        if diff < minDiff {
            toUse = spacing
            minDiff = diff
        }
    }
    
    let temp = stride(from: lower, through: upper, by: toUse)
    return Array(temp)
}

//Yes i can rewrite this to combine them with some protocol shit but i cant be bothered right now
func generateTicks(from lower: Date, through upper: Date, targetCount: Int, tickSpacings: [Double]) -> [Date] {
    var minDiff = Double.greatestFiniteMagnitude
    var toUse = 0.0
    
    for spacing in tickSpacings {
        let nTicks = Double(floor((upper.timeIntervalSince(lower))/spacing)) + 1
        let diff = abs(nTicks - Double(targetCount))
        
        if diff < minDiff {
            toUse = spacing
            minDiff = diff
        }
    }
    
    let temp = stride(from: lower, through: upper, by: toUse)
    var toReturn = Array(temp)
    return toReturn
}

extension Int {
    mutating func boundToRange(_ range: (Int, Int)) {
        if self > range.1 {
            self = self - range.1 + range.0 - 1
        } else if self < range.0 {
            self = self + range.1 - range.0 + 1
        }
    }
}

func getCrossingIndices<T: Comparable & Equatable>(_ arr: Array<T>, value: T) -> [Int] {
    //For finding the crossing indices of a concave down shape versus a horizontal line only! (actually just has to start below)
    var isAbove = false
    var toReturn = [Int]()
    
    for i in arr.indices {
        if i == 0 {continue}
        if isAbove {
            if arr[i] <= value {
                isAbove.toggle()
                toReturn.append(i)
            }
        } else {
            if arr[i] >= value {
                isAbove.toggle()
                toReturn.append(i)
            }
        }
    }
    return toReturn
}
