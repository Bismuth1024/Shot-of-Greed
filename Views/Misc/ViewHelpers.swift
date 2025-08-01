//
//  ViewHelpers.swift
//  Yesh
//
//  Created by Manith Kha on 12/1/2024.
//

import Foundation
import CoreGraphics
import UIKit
import SwiftUI

func relativeWidth(_ proportion: Double) -> CGFloat? {
    let screenBounds = UIScreen.main.bounds
    return proportion * screenBounds.width
}

func relativeHeight(_ proportion: Double) -> CGFloat? {
    let screenBounds = UIScreen.main.bounds
    return proportion * screenBounds.height
}

extension View {
    func titleOverlay(_ title: String) -> some View {
        ZStack(alignment: .top) {
            self
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Text(title)
                .font(.title)
                .bold()
                .padding(.top, 40)
        }
    }
}

/*
 func parentHeight() -> CGFloat {
 GeometryReader {metrics in
 metrics.size.height
 }
 }
 */
