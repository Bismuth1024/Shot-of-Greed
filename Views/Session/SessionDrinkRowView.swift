//
//  SessionDrinkRowView.swift
//  Shot of Greed
//
//  Created by Manith Kha on 23/7/2025.
//

import SwiftUI

struct SessionDrinkRowView: View {
    var Wrapper: DrinkingSession.SessionDrinkWrapper
    var body: some View {
        HStack {
            VStack {
                Text("\(Wrapper.drink.name) x \(Wrapper.quantity)")
                    .fontWeight(.bold)
                Spacer()
                if let endTime = Wrapper.endTime {
                    if endTime == Wrapper.startTime {
                        Text(DateHelpers.dateToTime(Wrapper.startTime))
                    } else {
                        Text(DateHelpers.twoDatesRangeString(Wrapper.startTime, endTime))
                    }
                } else {
                    Text("Started at " + DateHelpers.dateToTime(Wrapper.startTime))
                        .foregroundStyle(.blue)
                }
            }
            Spacer()
            VStack {
                Text(String(format: "%.2f standard drinks", Wrapper.drink.numStandards()))
                Spacer()
                Text(String(format: "%.2f g of sugar", Wrapper.drink.totalSugar()))
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    SessionDrinkRowView(Wrapper: .sample)
}
