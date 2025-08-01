//
//  SessionView.swift
//  Fwaeh
//
//  Created by Manith Kha on 23/1/2025.
//

import SwiftUI

struct SessionWrapperView: View {
    @EnvironmentObject var Manager: SessionManager
    var body: some View {
        ZStack {
            if Manager.hasActiveSession {
                SessionView()
                    .environmentObject(Manager.CurrentDrinkingSession!)
            } else {
                Button("New Session") {
                    Manager.startNewSession()
                    API.createSession(authSession: Manager.CurrentLoginSession!) { result in
                        switch (result) {
                        case .failure(let error):
                            fatalError(String(describing: error))
                        case .success(let data):
                            Manager.CurrentDrinkingSession!.id = data.new_session_id
                        }
                    }
                }
            }
        }
    }

}

#Preview {
    SessionWrapperView()
}
