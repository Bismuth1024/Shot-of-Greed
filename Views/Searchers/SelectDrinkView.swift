//
//  SelectDrinkView.swift
//  Shot of Greed
//
//  Created by Manith Kha on 18/7/2025.
//

import SwiftUI

/*
 Note that I use 'dummy' drink objects to get the tags of for excluding and excluding tags
 
 
 */

struct SelectDrinkView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var Manager: SessionManager
    @Binding var drink: AlcoholicDrink
    @State var SearchResults: [AlcoholicDrinkOverview] = []
    @State var requestingUpdate: Bool = false

    var body: some View {
        Form {
            Section("Search") {
                DrinkSearcherView(updateRequested: $requestingUpdate) { QueryParams in
                    refreshResults(QueryParams: QueryParams)
                }
                Button("Refresh") {
                    requestingUpdate = true
                }
            }
            
            Section("Drinks") {
                ForEach(SearchResults) { overview in
                    DrinkOverviewRowView(drink: overview)
                        .onTapGesture {
                            API.getDrink(authSession: Manager.CurrentLoginSession!, drinkID: overview.id) { result in
                                switch result {
                                case .failure(let error):
                                    fatalError(String(describing: error))
                                case .success(let fetchedDrink):
                                    DispatchQueue.main.async {
                                        drink = fetchedDrink
                                        dismiss()
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
    
    func refreshResults(QueryParams: DrinkQueryParams) {
        API.getDrinks(using: QueryParams) { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let response):
                DispatchQueue.main.async {
                    SearchResults = response
                }
            }
        }
    }
    
}

#Preview {
    SelectDrinkView(drink: .constant(AlcoholicDrink.Sample))
}
