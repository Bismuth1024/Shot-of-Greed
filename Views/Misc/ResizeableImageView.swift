//
//  UpdateableImageView.swift
//  Yeshica
//
//  Created by Manith Kha on 23/12/2022.
//

import SwiftUI

struct ResizeableImageView: View {
    var imageName: String
    let width: Int
    let height: Int
    
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: CGFloat(width), height: CGFloat(height))
    }
}

struct ResizeableImageView_Previews: PreviewProvider {
    static var previews: some View {
        ResizeableImageView(imageName: "Gin", width: 300, height: 300)
    }
}
