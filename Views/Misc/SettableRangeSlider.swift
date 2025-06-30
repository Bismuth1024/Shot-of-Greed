//
//  SettableRangeSlider.swift
//  Fwaeh
//
//  Created by Manith Kha on 30/1/2025.
//

import SwiftUI
import Sliders

struct SettableRangeSlider: View {
    var minMax : ClosedRange<Double> = 0...100.0
    @Binding var rangeValue: ClosedRange<Double>
    @State var lowerValue: Double = 0
    @State var upperValue: Double = 100
    
    init(minMax: ClosedRange<Double>, rangeValue: Binding<ClosedRange<Double>>) {
        self.minMax = minMax
        self._rangeValue = rangeValue
        self.lowerValue = minMax.upperBound
        self.upperValue = minMax.lowerBound
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(String(format: "%.1f", minMax.lowerBound))
                RangeSlider(range: $rangeValue, in : minMax)
                    .frame(height: 30)
                Text(String(format: "%.1f", minMax.upperBound))
            }
            TextField("Body mass", value: $lowerValue, format: .number.precision(.fractionLength(1)))
            TextField("Body mass", value: $upperValue, format: .number.precision(.fractionLength(1)))
            Spacer()
        }
        .onChange(of: rangeValue) {
            lowerValue = rangeValue.lowerBound
            upperValue = rangeValue.upperBound
        }
        .onChange(of: lowerValue) {
            rangeValue = lowerValue...upperValue
        }
        .onChange(of: upperValue) {
            rangeValue = lowerValue...upperValue
        }
        .onAppear() {
            rangeValue = max(rangeValue.lowerBound, minMax.lowerBound)...min(rangeValue.upperBound, minMax.upperBound)
        }
    }
}

#Preview {
    @Previewable @State var rangeValue = 0...50.0
    SettableRangeSlider(minMax: 0...100.0, rangeValue: $rangeValue)
}
