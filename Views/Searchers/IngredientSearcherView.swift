//
//  IngredientSearcherView.swift
//  Shot of Greed
//
//  Created by Manith Kha on 24/7/2025.
//

/*
 struct IngredientQueryParams: URLQueryConvertible {
     var name: String?
     var minABV: Double?
     var maxABV: Double?
     var minSugar: Double?
     var maxSugar: Double?
     var minDate: Date?
     var maxDate: Date?
     var includeTagIDs: [Int]?
     var excludeTagIDs: [Int]?
     var requireAllTags: Bool?
     var includePublic: Bool?
 */

import SwiftUI

struct IngredientSearcherView: View {
    @EnvironmentObject var Manager: SessionManager
    @Binding var updateRequested: Bool
    @FocusState var isFocused: Bool
    @State var IncludeTagsIngredient: DrinkIngredient = .Sample
    @State var ExcludeTagsIngredient: DrinkIngredient = .Sample
    @State var SearchResults: [DrinkIngredient] = []
    @State var ABVRange: ClosedRange<Double> = 0...100
    @State var SugarRange: ClosedRange<Double> = 0...100
    @State var LowerDate: Date = Date(timeIntervalSince1970: 0)
    @State var UpperDate: Date = Date(timeIntervalSinceNow: 0)
    @State var requireAllTags: Bool = true
    var onBuildQuery: (IngredientQueryParams) -> Void
    
    init(updateRequested: Binding<Bool>, IncludeTagsIngredient: DrinkIngredient = DrinkIngredient(), ExcludeTagsIngredient: DrinkIngredient = DrinkIngredient(), SearchResults: [DrinkIngredient] = [], ABVRange: ClosedRange<Double> = 0...100, SugarRange: ClosedRange<Double> = 0...100, LowerDate: Date = Date(timeIntervalSince1970: 0), UpperDate: Date = Date(timeIntervalSinceNow: 0), requireAllTags: Bool = true, _ onBuildQuery: @escaping (IngredientQueryParams) -> Void) {
        self._updateRequested = updateRequested
        self.IncludeTagsIngredient = IncludeTagsIngredient
        self.ExcludeTagsIngredient = ExcludeTagsIngredient
        self.SearchResults = SearchResults
        self.ABVRange = ABVRange
        self.SugarRange = SugarRange
        self.LowerDate = LowerDate
        self.UpperDate = UpperDate
        self.requireAllTags = requireAllTags
        self.onBuildQuery = onBuildQuery
    }
    
    var body: some View {
        DisclosureGroup("Filter parameters") {
            SettableRangeSlider("ABV", rangeValue: $ABVRange, minMax: 0...100, step: 0.01, nDecimal: 2)
            SettableRangeSlider("Sugar (%)", rangeValue: $SugarRange, minMax: 0...100, step: 0.01, nDecimal: 2)
        }
        DisclosureGroup("Include Tags") {
            Toggle(isOn: $requireAllTags) {
                Text(requireAllTags ? "All of:" : "Any of:")
            }
            TagEditor(object: $IncludeTagsIngredient, LoadedTags: Manager.CurrentTagsManager.IngredientTags)
        }
        DisclosureGroup("Exclude Tags") {
            TagEditor(object: $ExcludeTagsIngredient, LoadedTags: Manager.CurrentTagsManager.IngredientTags)
        }
        .focused($isFocused)
        .onChange(of: updateRequested) {
            if (!updateRequested) { return }
            let QueryParams = IngredientQueryParams(
                minABV: ABVRange.lowerBound,
                maxABV: ABVRange.upperBound,
                minSugar: SugarRange.lowerBound,
                maxSugar: SugarRange.upperBound,
                minDate: LowerDate,
                maxDate: Date(timeInterval: 60*60*24, since: UpperDate),
                includeTagIDs: IncludeTagsIngredient.tags.map{ $0.id },
                excludeTagIDs: ExcludeTagsIngredient.tags.map{ $0.id },
                requireAllTags: requireAllTags
            )
            updateRequested = false
            onBuildQuery(QueryParams)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isFocused = false
                }
            }
        }
    }
}

#Preview {
    IngredientSearcherView(updateRequested: .constant(false)) {_ in}
}
