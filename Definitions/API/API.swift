//
//  API.swift
//  Fwaeh
//
//  Created by Manith Kha on 8/1/2025.
//


/*
 When you are sending a http body and want optional fields, make sure you do compactmapvalues! this removes nil keys completely
 
 
 
 
 
 */

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
    
    static func handleRequest<T>(_ endpoint: String, method: String, queryParams: [URLQueryItem] = [], bodyData: Data? = nil, authSession: LoginSession? = nil, _ completion: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        let baseURL = APIURL.appendingPathComponent(endpoint)
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = queryParams;
        let requestURL = components.url!
        var request = URLRequest(url: requestURL)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        if let authSession = authSession {
            request.setValue("Bearer \(authSession.sessionToken)", forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request error: \(error)")
                return completion(.failure(error))
            }
            
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
    
    static func createUser(with request: UsersPostRequest, _ completion: @escaping (Result<NewUserIDResponse, Error>) -> Void) {
        let bodyData = try! JSONEncoder().encode(request)
        handleRequest("/users", method: "POST", bodyData: bodyData, completion)
    }
  
    static func createUser(username: String, password: String, email: String?, birthdate: Date, gender: String, _ completion: @escaping (Result<NewUserIDResponse, Error>) -> Void) {
        let request = UsersPostRequest(username: username, password: password, email: email, birthdate: birthdate, gender: gender)
        createUser(with: request, completion)
    }
    
    //Return/response value is the token for the login session
    static func loginUser(with request: LoginPostRequest, _ completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        let bodyData = try! JSONEncoder().encode(request)
        handleRequest("/login", method: "POST", bodyData: bodyData, completion)
    }
    
    static func loginUser(username: String, password: String, _ completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        let request = LoginPostRequest(username: username, password: password)
        loginUser(with: request, completion)
    }
    
    static func getIngredients(authSession: LoginSession? = nil, using params: IngredientQueryParams, _ completion: @escaping (Result<[DrinkIngredient], Error>) -> Void) {
        let queryParams = params.asURLQueryItems()
        handleRequest("/ingredients", method: "GET", queryParams: queryParams, completion)
    }
    
    static func createIngredient(authSession: LoginSession, ingredient: DrinkIngredient, _ completion: @escaping (Result<NewIngredientIDResponse, Error>) -> Void) {
        let body = IngredientsPostRequest(ingredient)
        let bodyData = try! JSONEncoder().encode(body)
        handleRequest("/ingredients", method: "POST", bodyData: bodyData, authSession: authSession, completion)
    }
    
    static func deleteIngredient(authSession: LoginSession, ingredientID: Int, _ completion: @escaping (Result<EmptyResponse, Error>) -> Void) {
        handleRequest("/ingredients/\(ingredientID)", method: "DELETE", authSession: authSession, completion)
    }
    
    static func getDrinks(authSession: LoginSession? = nil, using params: DrinkQueryParams, _ completion: @escaping (Result<[AlcoholicDrinkOverview], Error>) -> Void) {
        let queryParams = params.asURLQueryItems()
        handleRequest("/drinks", method: "GET", queryParams: queryParams, completion)
    }
    
    static func getDrink(authSession: LoginSession? = nil, drinkID: Int, _ completion: @escaping (Result<AlcoholicDrink, Error>) -> Void) {
        handleRequest("/drinks/\(drinkID)", method: "GET", authSession: authSession, completion)
    }
    
    static func createDrink(authSession: LoginSession, drink: AlcoholicDrink, _ completion: @escaping (Result<NewDrinkIDResponse, Error>) -> Void) {
        let body = DrinksPostRequest(drink)
        let bodyData = try! JSONEncoder().encode(body)
        handleRequest("/drinks", method: "POST", bodyData: bodyData, authSession: authSession, completion)
    }
    
    static func deleteDrink(authSession: LoginSession, drinkID: Int, _ completion: @escaping (Result<EmptyResponse, Error>) -> Void) {
        handleRequest("/drinks/\(drinkID)", method: "DELETE", authSession: authSession, completion)
    }
    
    static func createSession(authSession: LoginSession, _ completion: @escaping (Result<NewSessionIDResponse, Error>) -> Void) {
        handleRequest("/sessions", method: "POST", authSession: authSession, completion)
    }
    
    static func addDrinkToSession(authSession: LoginSession, sessionID: Int, with request: SessionDrinksPostRequest, _ completion: @escaping (Result<NewSessionDrinkIDResponse, Error>) -> Void) {
        handleRequest("/sessions/\(sessionID)/sessiondrinks", method: "POST", authSession: authSession, completion)
    }
    
    static func deleteSession(authSession: LoginSession, sessionID: Int, _ completion: @escaping (Result<EmptyResponse, Error>) -> Void) {
        handleRequest("/sessions/\(sessionID)", method: "DELETE", authSession: authSession, completion)
    }
    
    static func deleteSessionDrink(authSession: LoginSession, sessionID: Int, sessionDrinkID: Int, _ completion: @escaping (Result<EmptyResponse, Error>) -> Void) {
        handleRequest("/sessions/\(sessionID)/sessiondrinks/\(sessionDrinkID)", method: "DELETE", authSession: authSession, completion)
    }

    
    
    /*
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
     */
    
    
    //write templates for all api calls
    
    /*
     This function has scope for filtering the returned ingredients. Users are only able to fetch ingredients made by them or the system defaults.
     We can filter in app or in api - for now im gonna add filtering via api only, with a refresh button.
     filtering by tag is done in app cos this is harder in api hahaha im lazy
    
     */
    
    /*
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
     */
    

}
