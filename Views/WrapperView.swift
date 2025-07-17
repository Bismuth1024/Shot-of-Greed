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
    @EnvironmentObject var Manager : SessionManager
    var body: some View {
        NavigationView {
            if (Manager.isLoggedIn) {
                HomeTabsView()
            } else {
                ParentLoginView()
            }
        }
        .onAppear {
            //CurrentAppSession.tryLoad()
            
        }
    }
}

#Preview {
    WrapperView()
}
