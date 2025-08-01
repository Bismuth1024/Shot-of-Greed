//
//  SettableRangeSlider.swift
//  Fwaeh
//
//  Created by Manith Kha on 30/1/2025.
//

import SwiftUI
import Sliders

struct SettableRangeSlider: View {
    var title: String
    @Binding var rangeValue: ClosedRange<Double>
    var minMax: ClosedRange<Double> = 0...100
    var step: Double.Stride
    var nDecimal: Int

    @State private var lowerValue: Double
    @State private var upperValue: Double

    enum FocusField { case lower, upper }
    @FocusState private var focusedField: FocusField?

    init(_ title: String, rangeValue: Binding<ClosedRange<Double>>, minMax: ClosedRange<Double>, step: Double.Stride = 0.001, nDecimal: Int = 2) {
        self.title = title
        self._rangeValue = rangeValue
        self.minMax = minMax
        _lowerValue = State(initialValue: rangeValue.wrappedValue.lowerBound)
        _upperValue = State(initialValue: rangeValue.wrappedValue.upperBound)
        self.step = step
        self.nDecimal = nDecimal
    }

    var body: some View {
        VStack {
            HStack {
                TextField("Lower", value: $lowerValue, format: .number)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .lower)
                Spacer()
                Text(title)
                Spacer()
                TextField("Upper", value: $upperValue, format: .number)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .upper)
                    .multilineTextAlignment(.trailing)
            }
            RangeSlider(range: $rangeValue, in: minMax, step: step)
        
            .onChange(of: rangeValue) {
                lowerValue = rangeValue.lowerBound
                upperValue = rangeValue.upperBound
            }
        }
        
        .onChange(of: focusedField) {
            // Only validate when focus is lost
            if focusedField == nil {
                let clampedMin = min(max(lowerValue, minMax.lowerBound), upperValue)
                let roundedMin = Double(String(format: "%.\(nDecimal)f", clampedMin)) ?? 0
                let clampedMax = max(min(upperValue, minMax.upperBound), lowerValue)
                let roundedMax = Double(String(format: "%.\(nDecimal)f", clampedMax)) ?? 0
                rangeValue = roundedMin...roundedMax
                lowerValue = rangeValue.lowerBound
                upperValue = rangeValue.upperBound
            }
        }
    }
}


#Preview {
    @Previewable @State var rangeValue = 0...50.0
    SettableRangeSlider("test", rangeValue: $rangeValue, minMax: 0...100.0)
}
