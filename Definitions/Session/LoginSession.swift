//
//  AppSession.swift
//  Fwaeh
//
//  Created by Manith Kha on 9/1/2025.
//

import Foundation

/*Used to manage the current login session into the app.
 currentUser is the ID of the current User, matching with the MariaDB database.
 sessionToken is the login token retrieved from the API/database.
 
 When calls are made for actions that require user privileges, we pass the token in the auth HTTP header.
 
 The db can use this token to look up the user id, and technically can ignore the user id fields of anything
 e.g. when creating an ingredient, the whole struct with the created_user_id field is encoded to json and sent
 but the db will use the token to find the correct id anyway.
 
 */

struct LoginSession {
    var currentUser: Int
    var sessionToken: String
    
    func tryLoad() {
        
    }
    
    
}
