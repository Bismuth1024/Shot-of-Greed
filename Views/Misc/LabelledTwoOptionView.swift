//
//  TwoOptionView.swift
//  Yesh
//
//  Created by Manith Kha on 9/2/2024.
//

import SwiftUI

struct LabelledTwoOptionView<T : View, U : View>: View {
    @State var isFirstShowing: Bool
    var labelOne: String
    var labelTwo: String
    var ViewOne : T
    var ViewTwo : U
    
    init(_ labelOne: String, _ labelTwo: String, isFirstShowing: Bool, _ one: () -> T = {EmptyView()}, and two: () -> U = {EmptyView()}) {
        //TO FIX
        self.labelOne = labelOne
        self.labelTwo = labelTwo
        self.isFirstShowing = isFirstShowing
        ViewOne = one()
        ViewTwo = two()
    }
    
    
    var body: some View {
        VStack {
            Picker("type", selection: $isFirstShowing) {
                Text(labelOne).tag(true)
                Text(labelTwo).tag(false)
            }
            .pickerStyle(.segmented)
            .padding([.leading, .trailing, .bottom], 5)
            Spacer()
            TwoOptionView(isFirstShowing: $isFirstShowing) {
                ViewOne
            } and: {
                ViewTwo
            }
        }
    }
}

#Preview {
    LabelledTwoOptionView("One", "Two", isFirstShowing: true)
}
