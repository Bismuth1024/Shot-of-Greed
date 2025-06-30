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

/*
 func parentHeight() -> CGFloat {
 GeometryReader {metrics in
 metrics.size.height
 }
 }
 */
