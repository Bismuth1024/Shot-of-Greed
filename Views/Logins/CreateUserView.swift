//
//  CreateUserView.swift
//  Fwaeh
//
//  Created by Manith Kha on 10/1/2025.
//

import SwiftUI

struct CreateUserView: View {
    @State var email : String? = nil
    @State var username = ""
    @State var password = ""
    @State var password2 = ""
    @State var birthdate = Date()
    @State var gender = Gender.male
    @State var presentingAlert = false
    @State var alertMessage = ""
    @State var alertTitle = "Error"
    
    @State var isConnected : Bool? = nil
    
    var body: some View {
        Form {
            Section {
                OptionalTextField("Email (optional)", text: $email)
            }
            
            Section {
                DatePicker(
                    "Birthdate",
                    selection: $birthdate,
                    in: Date.distantPast...Date.now,
                    displayedComponents: [.date]
                )
                Picker("Gender", selection: $gender) {
                    Text("Male").tag(Gender.male)
                    Text("Female").tag(Gender.female)
                }
                .pickerStyle(.menu)
            }
            
            Section {
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
                SecureField("Confirm password", text: $password2)
            }
            
            Section {
                Button("Create User") {
                    validate()
                }
            }
            
            Section {
                VStack(spacing: 20) {
                    Button("Check Internet") {
                        checkInternetConnection { success in
                            isConnected = success
                        }
                    }

                    if let result = isConnected {
                        Text(result ? "Internet: ✅ Yes" : "Internet: ❌ No")
                            .foregroundColor(result ? .green : .red)
                    }
                }
            }
        }
        .alert(alertTitle, isPresented: $presentingAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
    }
    
    func validate() {
        if password != password2 {
            alertMessage = "Passwords do not match"
            alertTitle = "Error"
            presentingAlert = true
            return
        }
        
        if Date.now.timeIntervalSince(birthdate) < 18*365*24*60*60 {
            alertTitle = "Error"
            alertMessage = "Why are you using a drinking app if you are under 18..."
            presentingAlert = true
            return
        }
        
        API.createUser(username: username, password: password, email: email, birthdate: birthdate, gender: gender.rawValue) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                alertTitle = "Error"
                alertMessage = error.localizedDescription
                presentingAlert = true
            case .success(let response):
                print("new id \(response.new_user_id)")
                alertTitle = "Success"
                alertMessage = "Please login via the login tab"
                presentingAlert = true
            }
        }
    }
    
    func checkInternetConnection(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://www.apple.com/library/test/success.html") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 5 // seconds

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }
}

#Preview {
    CreateUserView()
}
