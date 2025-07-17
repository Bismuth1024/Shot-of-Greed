//
//  LoginView.swift
//  Fwaeh
//
//  Created by Manith Kha on 10/1/2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var Manager: SessionManager
    @State var username = ""
    @State var password = ""
    @State var presentingAlert = false
    @State var alertMessage = ""

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
                            Manager.CurrentLoginSession = LoginSession(currentUser: response.user_id, sessionToken: response.login_token)
                        }
                    }
                }
            }
            Button("Debug login") {
                API.loginUser(username: "test", password: "test") { result in
                    switch result {
                    case .failure(let error):
                        alertMessage = error.localizedDescription
                        presentingAlert = true
                    case .success(let response):
                        DispatchQueue.main.async {
                            Manager.CurrentLoginSession = LoginSession(currentUser: response.user_id, sessionToken: response.login_token)
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
