//
//  SessionView.swift
//  Fwaeh
//
//  Created by Manith Kha on 23/1/2025.
//

import SwiftUI

struct SessionView: View {
    @EnvironmentObject var Manager: SessionManager
    var CurrentSession: DrinkingSession {
        return Manager.CurrentDrinkingSession ?? DrinkingSession(startTime: Date.now)
    }
    @State var graphShowing: Bool = false
    @State var showingAddDrink: Bool = false
    var body: some View {
        VStack {
            if CurrentSession.endTime != nil {
                Text("Session (" + DateHelpers.dateToTime(CurrentSession.startTime) + " - " + DateHelpers.dateToDescription(CurrentSession.endTime ?? Date.now) + ")")
            } else {
                Text("Session (started " + DateHelpers.dateToDescription(CurrentSession.startTime) + ")")
            }
                 
            Picker("type", selection: $graphShowing) {
                Text("Graph").tag(true)
                Text("Drinks").tag(false)
            }
            .pickerStyle(.segmented)
            .padding([.leading, .trailing, .bottom], 5)
            
            TwoOptionView(isFirstShowing: $graphShowing) {
                GraphView()
            } and: {
                SessionDrinksView()
            }
            .frame(width: relativeWidth(0.9), height: relativeHeight(0.65))
            
            HStack {
                Button("Add Drink") {
                    showingAddDrink.toggle()
                }
                .sheet(isPresented: $showingAddDrink) {
                    NavigationStack {
                        AddDrinkView(isShowing: $showingAddDrink)
                    }
                }
                .padding()
                Spacer()
                Button("End Session") {
                    //isConfirmingEnd = true
                }
                .foregroundColor(.red)
                .padding()
            }
        }
    }
}

#Preview {
    SessionView()
}
