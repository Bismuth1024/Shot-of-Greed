//
//  LoginView.swift
//  Fwaeh
//
//  Created by Manith Kha on 10/1/2025.
//

import SwiftUI

struct LoginView: View {
    @State var username = ""
    @State var password = ""
    @State var presentingAlert = false
    @State var alertMessage = ""
    @EnvironmentObject var LoginSession: AppSession

    var body: some View {
        Form {
            TextField("Username", text: $username)
            SecureField("Password", text: $password)
            Button("Login") {
                API.loginUser(username: username, password: password) { result in
                    switch result {
                    case .failure(let error):
                        alertMessage = error.localizedDescription
                        presentingAlert = true
                    case .success(let response):
                        DispatchQueue.main.async {
                            LoginSession.sessionToken = response.login_token
                            LoginSession.currentUser = response.user_id
                        }
                    }
                }
            }
        }
        .alert("Error", isPresented: $presentingAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
    }
}

#Preview {
    LoginView()
}
