//
//  SafeButton.swift
//  Yesh
//
//  Created by Manith Kha on 20/1/2024.
//

import SwiftUI

struct SafeButton: View {
    var str: String
    var action: () -> Void
    
    init(_ str: String, action: @escaping () -> Void) {
        self.str = str
        self.action = action
    }
    
    var body: some View {
        Text(str)
            .onTapGesture(perform: action)
    }
}

#Preview {
    SafeButton("test", action: {})
}
