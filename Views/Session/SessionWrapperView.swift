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
            } else {
                Button("New Session") {
                    Manager.startNewSession()
                }
            }
        }
    }

}

#Preview {
    SessionWrapperView()
}
