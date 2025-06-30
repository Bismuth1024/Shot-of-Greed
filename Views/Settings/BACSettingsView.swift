//
//  BACSettingsView.swift
//  Yesh
//
//  Created by Manith Kha on 17/1/2024.
//

import SwiftUI

struct BACSettingsView: View {
    @AppStorage("bodyMass") var bodyMass: Double = Settings.Defaults["bodyMass"] as! Double
    @AppStorage("massUnits") var massUnits: String = Settings.Defaults["massUnits"] as! String
    @AppStorage("sex") var sex: String = Settings.Defaults["sex"] as! String
    @AppStorage("age") var age: Double = Settings.Defaults["age"] as! Double
    @AppStorage("height") var height: Double = Settings.Defaults["height"] as! Double
    @AppStorage("vdManual") var isVdManual: Bool = Settings.Defaults["vdManual"] as! Bool

    var allPhysiology: [String] {[
        bodyMass.description,
        massUnits,
        sex,
        age.description,
        height.description
    ]}
    
    @AppStorage("vd") var V_d: Double = Settings.Defaults["vd"] as! Double
    @AppStorage("t_step") var t_step: Double = Settings.Defaults["t_step"] as! Double
    @AppStorage("k_stomach") var k_stomach: Double = Settings.Defaults["k_stomach"] as! Double
    @AppStorage("k_blood") var k_blood: Double = Settings.Defaults["k_blood"] as! Double
    @AppStorage("m_blood") var m_blood: Double = Settings.Defaults["m_blood"] as! Double
    @AppStorage("BACextrapolationTarget") var BACextrapolationTarget: Double = Settings.Defaults["BACextrapolationTarget"] as! Double
    
    @State var isConfirmingDefault = false
    
    
    var body: some View {
        Form {
            Section(
                content: {
                    
                    VStack {
                        HStack {
                            Text("Body mass:")
                            TextField("Body mass", value: $bodyMass, format: .number.precision(.fractionLength(1)))
                            
                            Spacer()
                            
                            Picker("Units", selection: $massUnits) {
                                ForEach(Settings.MassUnits.allCases.map({$0.rawValue.0}), id: \.self) {unit in
                                    Text(unit)
                                }
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                            .frame(width: relativeWidth(0.3))
                        }
                        
                        Slider(value: $bodyMass, in: 20...150, step: 0.1) {
                            Text("test")
                        } minimumValueLabel: {
                            Text("20")
                        } maximumValueLabel: {
                            Text("150")
                        }
                    }
                    
                    Stepper(value: $age, in: 1...100) {
                        HStack {
                            Text("Age:")
                            TextField("Age", value: $age, format: .number.precision(.fractionLength(0)))
                        }
                    }
                    
                    InputSlider(name: "Height (cm)", value: $height, min: 120, max: 200, step: 0.1, nSigFigs: 4)
                    
                    HStack {
                        Text("Sex:")
                        Spacer()
                        Picker("Sex", selection: $sex) {
                            ForEach(Settings.Sex.allCases.map({$0.rawValue}), id: \.self) {s in
                                Text(s)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: relativeWidth(0.4))
                    }
                    
                    HStack {
                        Text("Volume of distribution:")
                        Spacer()
                        TextField("Vd", value: $V_d, format: .number.precision(.significantDigits(3)))
                            .disabled(!isVdManual)
                            .foregroundStyle(isVdManual ? .black : .gray)
                            .frame(width: relativeWidth(0.2))
                            .multilineTextAlignment(.center)
                        Spacer()
                        Picker("Vdmode", selection: $isVdManual) {
                            Text("Manual").tag(true)
                            Text("Auto").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .frame(width: relativeWidth(0.3))

                    }
                    
                    
                    
                    
                }, header: {
                    Text("Physiology")
                }
            )
            .onChange(of: allPhysiology) {_ in
                if isVdManual {return}
                V_d = Pharmacokinetics.calcuateVd(sex: sex, age: age, height: height, mass: bodyMass)
            }
            
            Section(
                content: {
                    InputSlider(name: "Time step (s)", value: $t_step, min: 5, max: 120, step: 1, nSigFigs: 3)
                    
                    InputSlider(name: "Stomach exponential coefficient", value: $k_stomach, min: 0.001, max: 0.01, step: 0.0001, nSigFigs: 2, valueWidth: 0.15)
                    
                    InputSlider(name: "Blood exponential coefficient", value: $k_blood, min: 0.0001, max: 0.005, step: 0.00001, nSigFigs: 2, valueWidth: 0.2)
                    
                    InputSlider(name: "Blood linear coefficient (BAC/h)", value: $m_blood, min: 0.01/3600, max: 0.035/3600, step: 0.0000001, nSigFigs: 2, scale: 3600, valueWidth: 0.15)
                    
                    InputSlider(name: "BAC extrapolation until (mg%):", value: $BACextrapolationTarget, min: 0.001, max: 0.1, step: 0.0001, nSigFigs: 2, valueWidth: 0.20)
                    
                    HStack {
                        Spacer()
                        Button(role: .destructive) {
                            isConfirmingDefault.toggle()
                        } label: {
                            Text("Restore Defaults")
                        }
                        .alert("Restore all settings to defaults?", isPresented: $isConfirmingDefault) {
                            Button(role: .destructive) {
                                restoreDefaults()
                            } label: {
                                Text("Restore defaults")
                            }
                        }
                    }
                    
                }, header: {
                    Text("BAC calculation parameters")
                    
                }
            )
        }
    }
    
    func restoreDefaults() {
        t_step = Settings.Defaults["t_step"] as! Double
        k_stomach = Settings.Defaults["k_stomach"] as! Double
        k_blood = Settings.Defaults["k_blood"] as! Double
        m_blood = Settings.Defaults["m_blood"] as! Double
        BACextrapolationTarget = Settings.Defaults["BACextrapolationTarget"] as! Double
    }
}

#Preview {
    BACSettingsView()
}
