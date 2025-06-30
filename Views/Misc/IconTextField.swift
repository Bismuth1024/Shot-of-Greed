//
//  IconTextField.swift
//  Yesh
//
//  Created by Manith Kha on 20/1/2024.
//

import SwiftUI

struct IconTextField: View {
    @Binding private var text: String
    var imageName: String
    var prompt: String
    
    init(_ imageName: String, text: Binding<String>, prompt: String = "") {
        self.imageName = imageName
        self._text = text
        self.prompt = prompt
    }

    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(.gray)
            TextField(prompt, text: $text)
        }
        .overlay(
          RoundedRectangle(cornerRadius: 6)
            .stroke(Color.gray, lineWidth: 1)
            .padding()
        )
    }
}

#Preview {
    IconTextField("search", text: .constant("test"))
}
