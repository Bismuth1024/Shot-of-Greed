//
//  CustomNavigationLink.swift
//  Yesh
//
//  Created by Manith Kha on 18/1/2024.
//

import SwiftUI

struct CustomNavigationLink<P: Hashable>: View {
    let str: String
    let value: P
    let textColour: Color
    let arrowColour: Color

    init(
        _ str: String,
        value: P,
        textColour: Color = .white,
        arrowColour: Color = .blue
    ) {
        self.str = str
        self.value = value
        self.textColour = textColour
        self.arrowColour = arrowColour
    }

    var body: some View {
        NavigationLink(value: value) {
            HStack {
                Text(str)
                Spacer()
                Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 7)
                    .foregroundColor(arrowColour)
            }
            .foregroundColor(textColour)
        }
        
    }
}
