//
//  LazyDate.swift
//  Yesh
//
//  Created by Manith Kha on 12/1/2024.
//

import Foundation

struct LazyDate : Equatable {
    var year: Int = 2000
    var month: Int = 1
    var day: Int = 1
    
    var str: String {
        return String(format: "%04d-%02d-%02d", year, month, day)
    }
    
    var date: Date {
        return LazyDate.formatter.date(from: str)!
    }
    
    static let sample = LazyDate(year: 2000, month: 1, day: 1)
    static var formatter: DateFormatter {
        let temp = DateFormatter()
        temp.dateFormat = "yyyy-MM-dd"
        return temp
    }
    
    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }
    
    init(from dateIn: Date) {
        let tempString = LazyDate.formatter.string(from: dateIn)
        self.init(tempString)
    }
    
    init(_ str: String) {
        //"yyyy-MM-dd"
        let yearStart = str.startIndex
        let yearEnd = str.index(str.startIndex, offsetBy: 3)
        
        let monthStart = str.index(str.startIndex, offsetBy: 5)
        let monthEnd = str.index(str.startIndex, offsetBy: 6)
    
        let dayStart = str.index(str.startIndex, offsetBy: 8)
        let dayEnd = str.index(str.startIndex, offsetBy: 9)
        
        self.year = Int(str[yearStart...yearEnd])!
        self.month = Int(str[monthStart...monthEnd])!
        self.day = Int(str[dayStart...dayEnd])!
    }
    
    func addDays(_ nDays: Int) -> LazyDate {
        //THIS ASSUMES YOU ARE ADDING LESS THAN A MONTH
        var newDate = self
        newDate.day += nDays
        newDate.correct()
        return newDate
    }
    
    func daysSince(_ other: LazyDate) -> Int {
        //ASSUMING LESS THAN 1 MONTH
        if other.year == year && other.month == month {
            return day - other.day
        } else {
            return (DateHelpers.daysInMonth(month: other.month, year: other.year) - other.day) + day
        }
    }
    
    func isInRange(from: LazyDate, to: LazyDate) -> Bool {
        if year < from.year || year > to.year {
            return false
        }
        if year > from.year && year < to.year {
            return true
        }
        if year == from.year {
            if month < from.month {
                return false
            } else if month == from.month && day < from.day {
                return false
            }
        }
        if year == to.year {
            if month > to.month {
                return false
            } else if month == to.month && day > to.day {
                return false
            }
        }
        return true
    }
    
    
    mutating func correct() {
        let upperBound = DateHelpers.daysInMonth(month: month, year: year)
        
        if day > upperBound {
            day -= upperBound
            month += 1
        } else if day < 1 {
            var previousMonth = month - 1
            previousMonth.boundToRange((1,12))
            let previousUpperBound = DateHelpers.daysInMonth(month: previousMonth, year: year)
            day = previousUpperBound + day
            month -= 1
        }
        
        if month > 12 {
            month = 1
            year += 1
        } else if month < 1 {
            month = 12
            year -= 1
        }
    }
}
