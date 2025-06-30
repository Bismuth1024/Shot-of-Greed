//
//  WrapperView.swift
//  Fwaeh
//
//  Created by Manith Kha on 10/1/2025.
//

import SwiftUI

struct CurrentViewWrapper {
    enum viewEnum {
        case login
        case BACSettings
        case customDrinks
        case customIngredients
    }
}

struct WrapperView: View {
    @StateObject var CurrentAppSession = AppSession()
    
    var body: some View {
        NavigationView {
            if (CurrentAppSession.sessionToken != nil) {
                HomeTabsView()
            } else {
                ParentLoginView()
            }
        }
        .onAppear {
            CurrentAppSession.tryLoad()
            
        }
        .environmentObject(CurrentAppSession)
    }
}

#Preview {
    WrapperView()
}
