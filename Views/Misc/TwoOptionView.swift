//
//  TwoOptionView.swift
//  Yesh
//
//  Created by Manith Kha on 9/2/2024.
//

import SwiftUI

struct TwoOptionView<T : View, U : View>: View {
    @Binding var isFirstShowing: Bool
    var ViewOne : T
    var ViewTwo : U
    
    init(isFirstShowing: Binding<Bool>, _ one: () -> T = {EmptyView()}, and two: () -> U = {EmptyView()}) {
        //TO FIX
        _isFirstShowing = isFirstShowing
        ViewOne = one()
        ViewTwo = two()
    }
    
    
    var body: some View {
        ZStack {
            ViewOne
                .opacity(isFirstShowing ? 1.0 : 0.0)
            
            ViewTwo
                .opacity(isFirstShowing ? 0.0 : 1.0)
        }
    }
}

#Preview {
    TwoOptionView(isFirstShowing: .constant(true))
}
