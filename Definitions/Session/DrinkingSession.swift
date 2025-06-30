//
//  DrinkingSession.swift
//  Fwaeh
//
//  Created by Manith Kha on 8/1/2025.
//

import Foundation

class DrinkingSession : ObservableObject, Codable {
    @Published var startTime: Date = Date()
    @Published var endTime: Date? = nil
    @Published var drinks: [DrinkWrapper] = []
    
    //just wraps a drink with a start and end time for when it was drunk
    struct DrinkWrapper : Hashable, Identifiable, Codable, Equatable {
        var drink: AlcoholicDrink
        var startTime: Date
        var endTime: Date?
        
        //Because this should be unique
        var id : Date {
            startTime
        }
        
        init(drink: AlcoholicDrink, startTime: Date, endTime: Date? = nil) {
            self.drink = drink
            self.startTime = startTime
            self.endTime = endTime
        }
        
        init(drink: AlcoholicDrink, shotAt time: Date) {
            self.drink = drink
            self.startTime = time
            self.endTime = time
        }
        
        func description() -> String {
            var str = drink.name + ", "
            if let endTime = endTime {
                if endTime == startTime {
                    str += DateHelpers.dateToTime(startTime)
                } else {
                    str += DateHelpers.twoDatesRangeString(startTime, endTime)
                }
            } else {
                str += "started at " + DateHelpers.dateToTime(startTime)
            }
            return str
        }
        
        static var sample: DrinkWrapper = DrinkWrapper(drink: AlcoholicDrink.Sample, startTime: Date(), endTime: Date(timeInterval: 100, since: Date()))
    }
    
    enum CodingKeys: CodingKey {
        case startTime, endTime, drinks
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(drinks, forKey: .drinks)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date?.self, forKey: .endTime)
        drinks = try container.decode([DrinkWrapper].self, forKey: .drinks)
    }
    
    
    static let CurrentSessionURL : URL = documentsURL().appendingPathComponent("CurrentSession.data")

    //The Date Formatter to use for session log file names decoding/encoding
    
    static var FilenameFormatter : DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH:mm"
        return formatter
    }
    
    //The URL for saving a completed log
    var completedSessionURL : URL {
        return sessionLogsURL().appendingPathComponent(DrinkingSession.FilenameFormatter.string(from: startTime))
    }
    
    func saveCurrentSession() {
        save(self, to: DrinkingSession.CurrentSessionURL) {result in
            if case .failure(let error) = result {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveCompletedSession() {
        save(self, to: completedSessionURL) {result in
            if case .failure(let error) = result {
                print(error.localizedDescription)
            }
        }
    }
    
    @discardableResult static func removeCurrentSession() -> Bool {
        do {
            try FileManager.default.removeItem(at: CurrentSessionURL)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func rawData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
}
