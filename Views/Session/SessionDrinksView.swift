//
//  SessionDrinksView.swift
//  Shot of Greed
//
//  Created by Manith Kha on 17/7/2025.
//

import SwiftUI

struct SessionDrinksView: View {
    @EnvironmentObject var Manager: SessionManager
    @EnvironmentObject var CurrentSession: DrinkingSession
    @State var isFinishingDrink: Bool = false
    @State var focusedIndex: Int? = nil
    
    var body: some View {
        VStack {
            Button("Test") {
                for drink in CurrentSession.drinks {
                    print(drink.id)
                }
            }
            List {
                ForEach(CurrentSession.drinks) { wrapper in
                    SessionDrinkRowView(Wrapper: wrapper)
                        .onTapGesture {
                            if wrapper.endTime != nil { return }
                            focusedIndex = CurrentSession.drinks.firstIndex(where: {$0.id == wrapper.id})
                            isFinishingDrink = true
                        }
                }
            }
        }
        .alert("Finish this drink now?", isPresented: $isFinishingDrink) {
            Button("Ok", role: .destructive) {
                let finishTime = Date()
                let drinkID = CurrentSession.drinks[focusedIndex!].id
                CurrentSession.drinks[focusedIndex!].endTime = finishTime
                API.finishSessionDrink(authSession: Manager.CurrentLoginSession!, sessionID: CurrentSession.id, sessionDrinkID: drinkID, with: SessionDrinksPatchRequest(end_time: finishTime)) { result in
                    switch result {
                    case .failure(let error):
                        fatalError(String(describing: error))
                    case .success(let response):
                        print("A")
                    }
                }
            }
            Button("Cancel", role: .cancel) {
                
            }
        }
    }
}

#Preview {
    SessionDrinksView()
}
