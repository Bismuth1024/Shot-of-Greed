//
//  DateHelpers.swift
//  Yesh
//
//  Created by Manith Kha on 19/12/2023.
//

/*
 A file containing a "namespace" of some functions that help with manipulating dates.
 
 
 
 
 
 */

import Foundation


struct DateHelpers {
    
    
    //A bunch of useful things that are hopefully self-explanatory
    static let validYears = Array(2000...2050)
    static let validMonths = Array(1...12)
    static let numToMonth = [   1 : "January",
                                2 : "February",
                                3 : "March",
                                4 : "April",
                                5 : "May",
                                6 : "June",
                                7 : "July",
                                8 : "August",
                                9 : "September",
                                10 : "October",
                                11 : "November",
                                12 : "December"
    ]
    static let daysInMonth = [  1 : 31,
                                2 : 28,
                                3 : 31,
                                4 : 30,
                                5 : 31,
                                6 : 30,
                                7 : 31,
                                8 : 31,
                                9 : 30,
                                10 : 31,
                                11 : 30,
                                12 : 31
    ]
    
    static let weekDayNames = Calendar(identifier: .gregorian).weekdaySymbols
    
    //For when functions can output 4 hours 3 min, or 4 hours 3 min 20 sec for example: use [TimeComponents] as an arg
    enum TimeComponents : CaseIterable {
        case second, minute, hour, day, week, month, year
    }
    
    //Returns what day a date is of the month, e.g. 24 for 24th Feb
    static func dayOfMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
    
    //Returns what month a date is of the year, e.g. 4 for 3rd April
    static func monthNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        return formatter.string(from: date)
    }
    
    //Returns the year for a date
    static func getYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    
    //Do i really need to comment this shit
    static func isInLeapYear(_ date: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year], from: date)
        let year = components.year!
        return isLeapYear(year)
    }
    
    static func isLeapYear(_ year: Int) -> Bool {
        return (year % 4 == 0)
    }
    
    static func daysInYear(_ year: Int) -> Int {
        isLeapYear(year) ? 366 : 365
    }
    
    static func daysBetweenYears(_ years: (Int, Int)) -> Int {
        //Not inclusive
        let end = years.1 - 1
        let start = years.0
        let nYears = end - start + 1
        var nLeapYears = ((end - end % 4) - (start + (4 - start % 4)))
        nLeapYears = nLeapYears < 0 ? 0 : nLeapYears >> 2 + 1
        return nYears * 365 + nLeapYears
    }
    
    //idk this shit
    static func daysBetween(month1: Int, month2: Int, startYear: Int) -> Int {
        var currentYear = startYear
        var toReturn = 0
        if month2 < month1 {
            for month in month1...12 {
                toReturn += daysInMonth(month: month, year: currentYear)
            }
            currentYear += 1
        }
        for month in 1..<month2 {
            toReturn += daysInMonth(month: month, year: currentYear)
        }
        return toReturn
    }
    
    static func daysInMonth(month: Int, year: Int) -> Int {
        var toReturn = daysInMonth[month]!
        if month == 2 && isLeapYear(year) {
            toReturn += 1
        }
        return toReturn
    }
    
    //Prints a 04:21 am string from a date
    static func dateToTime(_ date: Date) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.hour, .minute], from: date)
        var hour = components.hour!
        let temp: String = (hour >= 12) ? "pm" : "am"
        hour = hour % 12
        hour = (hour == 0) ? 12 : hour
        return String(format: "%02d:%02d ", hour, components.minute!) + temp
    }
    
    //14 May 2021
    static func dateToCalendarDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        return (formatter.string(from: date))
    }
    
    //Prints a 16:55 string from a date
    static func dateToTime24(_ date: Date) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return String(format: "%02d:%02d", components.hour!, components.minute!)
    }
    
    //Prints a 5:04 pm, 21 Oct 2024 (i think)
    static func dateToDescription(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a, d MMM y"
        return (formatter.string(from: date))
    }
    
    //Prints a Monday, 21 Sep 2021
    static func dateToDayDescription(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM y"
        return (formatter.string(from: date))
    }
    
    static func dateToWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return (formatter.string(from: date))
    }
    
    //Gives something like 6:12 - 6:35 pm, should only be used for a small range of a few minutes or hours
    static func twoDatesRangeString(_ d1: Date, _ d2: Date) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let components1 = calendar.dateComponents([.hour, .minute], from: d1)
        let components2 = calendar.dateComponents([.hour, .minute], from: d2)
        var hour1 = components1.hour!
        var hour2 = components2.hour!

        let temp: String = (hour2 >= 12) ? "pm" : "am"
        hour2 = hour2 % 12
        hour2 = (hour2 == 0) ? 12 : hour2
        hour1 = hour1 % 12
        hour1 = (hour1 == 0) ? 12 : hour1
        return String(format: "%02d:%02d - %02d:%02d ", hour1, components1.minute!, hour2, components2.minute!) + temp
    }
    
    //Converts seconds to the format you want: specify components 
    static func secondsTo(_ components: [TimeComponents], value: Int) -> String {
        let (hour, min, sec) = (value / 3600, (value % 3600) / 60, (value % 3600) % 60)
        var toReturn = ""
        if components.contains(.hour) {
            toReturn = toReturn + "\(hour) " + (hour == 1 ? "hour" : "hours")
        }
        if components.contains(.minute) {
            toReturn = toReturn + (toReturn.isEmpty ? "" : ", ") + "\(min) " + (min == 1 ? "minute" : "minutes")
        }
        if components.contains(.second) {
            toReturn = toReturn + (toReturn.isEmpty ? "" : ", ") + "\(sec) " + (sec == 1 ? "second" : "seconds")
        }
        return toReturn
    }
    
    static var FirstOfYear = DateComponents(month: 1, day: 1)
    static var FirstOfMonth = DateComponents(day: 1)
    static var FirstOfWeek = DateComponents(weekday : 1)
    
    
    
    static func getFirstsOf(_ component: Calendar.Component, startTime: Date, endTime: Date, includeEarlier: Bool = false) -> [Date] {
        var components: DateComponents
        switch component {
        case .weekday:
            components = FirstOfWeek
        case .month:
            components = FirstOfMonth
        case .year:
            components = FirstOfYear
        default:
            return []
        }
        
        var toReturn = [Date]()
        
        Calendar(identifier: .gregorian).enumerateDates(startingAfter: endTime, matching: components, matchingPolicy: .strict, direction: .backward) {result,exactMatch,stop in
            if let result {
                if result < startTime {
                    stop = true
                    if !includeEarlier {
                        return
                    }
                }
                toReturn.append(result)
            
            }
        }
        return toReturn
    }
    
    static func nextFirstOf(_ component: Calendar.Component, from date: Date) -> Date {
        var components: DateComponents
        switch component {
        case .weekday:
            components = FirstOfWeek
        case .month:
            components = FirstOfMonth
        case .year:
            components = FirstOfYear
        default:
            fatalError("u didnt use this function properly")
        }
        return Calendar(identifier: .gregorian).nextDate(after: date, matching: components, matchingPolicy: .strict)!
    }
    
    static func nextWeekday(after date: Date, weekday: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: date)
        
        return calendar.nextDate(after: date, matching: components, matchingPolicy: .strict)!
    }
    
    static func weekAfter(_ date: Date) -> Date {
        let weekday = Calendar(identifier: .gregorian).dateComponents([.weekday], from: date).weekday!
        return nextWeekday(after: date, weekday: weekday)
    }
    
    static func dayAfter(_ date: Date) -> Date {
        let components = DateComponents(hour: 0)
        return Calendar(identifier: .gregorian).nextDate(after: date, matching: components, matchingPolicy: .strict)!
    }
    
    

    /*
    static func getRecentWeekday(weekday: Int, before date: Date) -> LazyDate {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: date)
        let daysBefore = (components.weekday! + 7 - weekday) % 7
        
        let lazyDate = LazyDate(from: date)
        let outDate = lazyDate.addDays(-daysBefore)
        return outDate
    }
     */
    
    static func makeDate(year: Int, month: Int, day: Int) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components)
    }
    
    static func earliest(_ d1: Date, _ d2: Date) -> Date {
        return d1 < d2 ? d1 : d2
    }
    
    static func latest(_ d1: Date, _ d2: Date) -> Date {
        return d1 < d2 ? d2 : d1
    }
    
    static func isSameDay(_ d1: Date, _ d2: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components1 = calendar.dateComponents([.day, .year, .month], from: d1)
        let components2 = calendar.dateComponents([.day, .year, .month], from: d2)
        
        return components1 == components2
    }
    
    static var JSDateFormatter : ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        
        // Configure the formatter for fractional seconds and UTC time zone
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
    
    static var SQLDateFormatter : DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

}



