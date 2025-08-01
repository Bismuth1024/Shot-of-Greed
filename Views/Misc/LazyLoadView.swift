//
//  LazyLoadView.swift
//  Shot of Greed
//
//  Created by Manith Kha on 1/8/2025.
//

import SwiftUI

struct LazyLoadView<ID: Hashable, DataType, Content: View>: View {
    let id: ID
    let loader: (ID) async throws -> DataType
    let content: (DataType) -> Content
    
    @State private var data: DataType?
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        Group {
            if let data = data {
                content(data)
            } else if isLoading {
                ProgressView()
            } else if let error = error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else {
                Color.clear.onAppear(perform: loadData)
            }
        }
    }
    
    private func loadData() {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        
        Task {
            do {
                let result = try await loader(id)
                await MainActor.run {
                    data = result
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    isLoading = false
                }
            }
        }
    }
}


#Preview {
    EmptyView()
}
