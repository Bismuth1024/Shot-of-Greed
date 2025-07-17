//
//  SessionManager.swift
//  Shot of Greed
//
//  Created by Manith Kha on 17/7/2025.
//

import Foundation

class SessionManager : ObservableObject {
    @Published var CurrentDrinkingSession : DrinkingSession? = nil {
        didSet {
                    print("CurrentDrinkingSession changed: \(String(describing: CurrentDrinkingSession))")
                }
        }
    @Published var CurrentLoginSession : LoginSession? = nil
    
    func startNewSession() {
        CurrentDrinkingSession = DrinkingSession()
    }
    
    func clearSession() {
        CurrentDrinkingSession = nil
    }
    
    var hasActiveSession : Bool {
        return CurrentDrinkingSession != nil
    }
    
    var isLoggedIn : Bool {
        return CurrentLoginSession != nil
    }
}

