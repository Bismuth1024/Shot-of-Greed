//
//  DoubleSlider.swift
//  Yesh
//
//  Created by Manith Kha on 17/1/2024.
//

import SwiftUI

struct InputSlider: View {
    var name: String
    @Binding var value: Double
    var min: Double
    var max: Double
    var step: Double
    var nSigFigs: Int = 3
    var scale: Double = 1.0 //in case you want to display different units
    var valueWidth: Double = 0.3
    
    var body: some View {
        let formatter = numberFormatter.precision(.significantDigits(nSigFigs)).scale(scale)
        VStack {
            HStack {
                Text(name)
                
                Spacer()
                
                TextField(name, value: $value, format: formatter)
                    .multilineTextAlignment(.trailing)
                    .onSubmit {
                        if value < min {
                            value = min
                        } else if value > max {
                            value = max
                        }
                    }
                    .frame(width: relativeWidth(valueWidth))
            }
            
            Slider(value: $value, in: min...max, step: step) {
                Text("")
            } minimumValueLabel: {
                Text(formatter.format(min))
            } maximumValueLabel: {
                Text(formatter.format(max))
            }
        }
    }
    
    var numberFormatter = FloatingPointFormatStyle<Double>.number
}

#Preview {
    InputSlider(name: "test", value: .constant(50), min: 1, max: 100, step: 1)
}
