//
//  APIHelpers.swift
//  Shot of Greed
//
//  Created by Manith Kha on 15/7/2025.
//

import Foundation

// This section is used for more easily passing optional values into the query string of a http request
protocol QueryStringConvertible {
    var queryStringValue: String { get }
}

extension String: QueryStringConvertible {
    var queryStringValue: String { self }
}

extension Int: QueryStringConvertible {
    var queryStringValue: String { String(self) }
}

extension Bool: QueryStringConvertible {
    var queryStringValue: String { String(self) }
}

extension Double: QueryStringConvertible {
    var queryStringValue: String { String(self) }
}

extension Date: QueryStringConvertible {
    var queryStringValue: String {
        DateHelpers.JSDateFormatter.string(from: self)
    }
}

extension Array: QueryStringConvertible where Element: QueryStringConvertible {
    var queryStringValue: String {
        self.map { $0.queryStringValue }.joined(separator: ",")
    }
}

extension URLQueryItem {
    static func optional<T: QueryStringConvertible>(_ name: String, _ value: T?) -> URLQueryItem? {
        guard let value else { return nil }
        return URLQueryItem(name: name, value: value.queryStringValue)
    }
}
