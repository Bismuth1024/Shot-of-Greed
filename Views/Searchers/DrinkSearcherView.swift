//
//  DrinkSearcherView.swift
//  Shot of Greed
//
//  Created by Manith Kha on 22/7/2025.
//

import SwiftUI

struct DrinkSearcherView: View {
    @EnvironmentObject var Manager: SessionManager
    @Binding var updateRequested: Bool
    @FocusState var isFocused: Bool
    @State var IncludeTagsDrink: AlcoholicDrink = AlcoholicDrink()
    @State var ExcludeTagsDrink: AlcoholicDrink = AlcoholicDrink()
    @State var SearchResults: [AlcoholicDrinkOverview] = []
    @State var StandardsRange: ClosedRange<Double> = 0...5
    @State var SugarRange: ClosedRange<Double> = 0...50
    @State var IngredientsRange: ClosedRange<Double> = 1...10
    @State var LowerDate: Date = Date(timeIntervalSince1970: 0)
    @State var UpperDate: Date = Date(timeIntervalSinceNow: 0)
    @State var requireAllTags: Bool = true
    var onBuildQuery: (DrinkQueryParams) -> Void
    
    init(updateRequested: Binding<Bool>, IncludeTagsDrink: AlcoholicDrink = AlcoholicDrink(), ExcludeTagsDrink: AlcoholicDrink = AlcoholicDrink(), SearchResults: [AlcoholicDrinkOverview] = [], StandardsRange: ClosedRange<Double> = 0...5, SugarRange: ClosedRange<Double> = 0...50, IngredientsRange: ClosedRange<Double> = 1...10, LowerDate: Date = Date(timeIntervalSince1970: 0), UpperDate: Date = Date(timeIntervalSinceNow: 0), requireAllTags: Bool = true, _ onBuildQuery: @escaping (DrinkQueryParams) -> Void) {
        self._updateRequested = updateRequested
        self.IncludeTagsDrink = IncludeTagsDrink
        self.ExcludeTagsDrink = ExcludeTagsDrink
        self.SearchResults = SearchResults
        self.StandardsRange = StandardsRange
        self.SugarRange = SugarRange
        self.IngredientsRange = IngredientsRange
        self.LowerDate = LowerDate
        self.UpperDate = UpperDate
        self.requireAllTags = requireAllTags
        self.onBuildQuery = onBuildQuery
    }
    
    
    var body: some View {
        DisclosureGroup("Filter Parameters") {
            SettableRangeSlider("Standards", rangeValue: $StandardsRange, minMax: 0...5, step: 0.01)
            SettableRangeSlider("Sugar (g)", rangeValue: $SugarRange, minMax: 0...50, step: 0.01)
            SettableRangeSlider("Ingredients", rangeValue: $IngredientsRange, minMax: 1...10, step: 1, nDecimal: 0)
            DatePicker("Created after", selection: $LowerDate, displayedComponents: [.date])
            DatePicker("Created before", selection: $UpperDate, displayedComponents: [.date])
        }
        .focused($isFocused)
        DisclosureGroup("Include Tags") {
            Toggle(isOn: $requireAllTags) {
                Text(requireAllTags ? "All of:" : "Any of:")
            }
            TagEditor(object: $IncludeTagsDrink, LoadedTags: Manager.CurrentTagsManager.DrinkTags)
        }
        DisclosureGroup("Exclude Tags") {
            TagEditor(object: $ExcludeTagsDrink, LoadedTags: Manager.CurrentTagsManager.DrinkTags)
        }
        .onChange(of: updateRequested) {
            if (!updateRequested) { return }
            let QueryParams = DrinkQueryParams(
                minStandards: StandardsRange.lowerBound,
                maxStandards: StandardsRange.upperBound,
                minIngredients: Int(IngredientsRange.lowerBound),
                maxIngredients: Int(IngredientsRange.upperBound),
                minSugar: SugarRange.lowerBound,
                maxSugar: SugarRange.upperBound,
                minDate: LowerDate,
                maxDate: Date(timeInterval: 60*60*24, since: UpperDate), // Because we want to include this day
                includeTagIDs: IncludeTagsDrink.tags.map{ $0.id },
                excludeTagIDs: ExcludeTagsDrink.tags.map{ $0.id },
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
    DrinkSearcherView(updateRequested: .constant(false)) { _ in
        
    }
}
