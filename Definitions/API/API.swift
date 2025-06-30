//
//  API.swift
//  Fwaeh
//
//  Created by Manith Kha on 8/1/2025.
//

import Foundation

typealias JSONDict = [String: Any]

struct API {
    
    
    
    static let APIURL = URL(string: "https://yesh123.duckdns.org:3000/api")!
    
    //FIX THIS TO MAKE IT SECURE SOON NO RAW PASSWORDS!!
    /*
     API call to create a user.
     
     response:
     
     good:
        {
            201
            id: new user id
        }
     
     bad:
        {
            
     */
    
    /*
     for post requests that take json in the body and return either
     most requests to create a codable object have the id already in the object.
     This is just a dummy value, once the database creates it in the table,
     the real id will be returned as a response
     good:
        {
            201
            id: new user id (it can be any single return value)
        }
     
     bad:
        {
            message: ""
        }
     
     */
    static func handlePostRequest<T>(_ endpoint: String, _ requestData: Data, authSession: AppSession? = nil, _ completion: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        let requestURL = APIURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData
        if let authSession = authSession {
            request.setValue("Bearer \(authSession.sessionToken!)", forHTTPHeaderField: "Authorization")
        }
        
        let session = URLSession.shared

        let task = session.dataTask(with: request) { data, response, error in
            // Handle errors
            if let error = error {
                print("Request error: \(error)")
                return completion(.failure(error))
            }
            
            // Handle the response status code
            /*
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 201 {
                print("HTTP Error: \(httpResponse.statusCode)")
                completion(.failure(GenericError(message: "propagate HTTP Error: \(httpResponse.statusCode)")))
            }
             */
            
            if let data = data {
                do {
                    // Attempt to convert the raw Data into a human-readable JSON format
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)

                    // Convert the JSON object back to pretty-printed JSON data
                    let prettyPrintedData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                    
                    // Convert the pretty-printed data to a string
                    if let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
                        print(prettyPrintedString)  // Human-readable JSON
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let response = try decoder.decode(APIResponse<T>.self, from: data)
                    
                    switch response.result {
                    case .success(let successData):
                        completion(.success(successData))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    static func handleGetRequest<T>(_ endpoint: String, parameters: [URLQueryItem], authSession: AppSession? = nil, _ completion: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        
        let baseURL = APIURL.appendingPathComponent(endpoint)
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = parameters;
        let requestURL = components.url!
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let authSession = authSession {
            request.setValue("Bearer \(authSession.sessionToken!)", forHTTPHeaderField: "Authorization")
        }
        
        let session = URLSession.shared

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request error: \(error)")
                return completion(.failure(error))
            }
            
            // Handle the response status code
            /*
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 201 {
                print("HTTP Error: \(httpResponse.statusCode)")
                completion(.failure(GenericError(message: "propagate HTTP Error: \(httpResponse.statusCode)")))
            }
             */
            
            if let data = data {
                do {
                    // Attempt to convert the raw Data into a human-readable JSON format
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)

                    // Convert the JSON object back to pretty-printed JSON data
                    let prettyPrintedData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                    
                    // Convert the pretty-printed data to a string
                    if let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
                        print(prettyPrintedString)  // Human-readable JSON
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let response = try decoder.decode(APIResponse<T>.self, from: data)
                    
                    switch response.result {
                    case .success(let successData):
                        completion(.success(successData))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
            
    static func createUser(username: String, password: String, email: String?, birthdate: Date, gender: String, _ completion: @escaping (Result<NewIDResponse, Error>) -> Void) {
        
        let parsedDate = DateHelpers.SQLDateFormatter.string(from: birthdate)
        
        let rawBody : JSONDict = [
            "username": username,
            "password": password,
            "email": email,
            "birthdate": parsedDate,
            "gender": gender
        ].compactMapValues{$0}
        
        print(rawBody)
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: rawBody, options: [])
            print(bodyData)
            handlePostRequest("/users", bodyData, completion)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    //Return/response value is the token for the login session
    static func loginUser(username: String, password: String, _ completion: @escaping (Result<LoginResponse, Error>) -> Void) {

        let rawBody : JSONDict = [
            "username" : username,
            "password" : password
        ]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: rawBody, options: [])
        
        handlePostRequest("/login", bodyData, completion)
    }
    
    static func createIngredient(authSession: AppSession, ingredient: DrinkIngredient, _ completion: @escaping (Result<Int, Error>) -> Void) {
        do {
            let rawBody = try JSONEncoder().encode(ingredient)
            handlePostRequest("/ingredients", rawBody, authSession: authSession, completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    static func createDrink(authSession: AppSession, drink: AlcoholicDrink, _ completion: @escaping (Result<Int, Error>) -> Void) {
        
        do {
            let rawBody = try JSONEncoder().encode(drink)
            handlePostRequest("/drinks", rawBody, authSession: authSession, completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    static func createTag(tag: Tag, _ completion: @escaping (Result<Int, Error>) -> Void) {
        do {
            let rawBody = try JSONEncoder().encode(tag)
            handlePostRequest("/tags", rawBody, completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    static func createSession(authSession: AppSession, session: DrinkingSession, _ completion: @escaping (Result<Int,Error>) -> Void) {
        do {
            let rawBody = try JSONEncoder().encode(session)
            handlePostRequest("/sessions", rawBody, authSession: authSession, completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    static func getTags(type: String?, completion: @escaping (Result<TagsResponse, Error>) -> Void) {
        print("called with \(type ?? "none")")
        do {
            var parameters = [URLQueryItem]()
            if let type = type {
                parameters.append(URLQueryItem(name: "type", value: type))
            }
            handleGetRequest("/tags", parameters: parameters, completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    
    //write templates for all api calls
    
    /*
     This function has scope for filtering the returned ingredients. Users are only able to fetch ingredients made by them or the system defaults.
     We can filter in app or in api - for now im gonna add filtering via api only, with a refresh button.
     filtering by tag is done in app cos this is harder in api hahaha im lazy
    
     */
    static func getIngredients(authSession: AppSession, userID: Int, minABV: Double?, maxABV: Double?, minSugar: Double?, maxSugar: Double?, minDate: Date?, maxDate: Date?, completion: @escaping (Result<IngredientsResponse, Error>) -> Void) {
        
        let parameters = [
            minABV == nil ? nil : URLQueryItem(name: "min_ABV", value: String(minABV!)),
            maxABV == nil ? nil : URLQueryItem(name: "max_ABV", value: String(maxABV!)),
            minSugar == nil ? nil : URLQueryItem(name: "min_sugar", value: String(minSugar!)),
            maxSugar == nil ? nil : URLQueryItem(name: "max_sugar", value: String(maxSugar!)),
            minDate == nil ? nil : URLQueryItem(name: "min_date", value: DateHelpers.JSDateFormatter.string(from: minDate!)),
            maxDate == nil ? nil : URLQueryItem(name: "max_date", value: DateHelpers.JSDateFormatter.string(from: maxDate!))
        ].compactMap {$0}
        
        handleGetRequest("ingredients", parameters: parameters, authSession: authSession, completion)
    }
    
    static func getDrinks() {
        
    }
    

}
