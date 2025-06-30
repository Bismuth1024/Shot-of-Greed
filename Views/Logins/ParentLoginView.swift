//
//  ParentLoginView.swift
//  Fwaeh
//
//  Created by Manith Kha on 10/1/2025.
//

import SwiftUI

struct ParentLoginView: View {
    @EnvironmentObject var loginSession: AppSession
    var body: some View {
        LabelledTwoOptionView("Login", "Create Account", isFirstShowing: true) {
            LoginView()
        } and: {
            CreateUserView()
        }
    }
}

#Preview {
    ParentLoginView()
}
