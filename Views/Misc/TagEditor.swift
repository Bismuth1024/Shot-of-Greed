//
//  TagEditor.swift
//  Yesh
//
//  Created by Manith Kha on 23/1/2024.
//

import SwiftUI

struct TagEditor<T: Taggable>: View {
    @Binding var object: T
    var type: String? = nil
    var isSearchable = false
    @State var LoadedTags = [Tag]()
    @State var tagSearchText = ""
    
    var searchResults: [Tag] {
        var tags = LoadedTags.filter({!object.hasTag($0)})
        
        if let type = type {
            tags = tags.filter( {$0.type == type} )
        }
        
        if !tagSearchText.isEmpty {
            return tags.filter({$0.name.contains(tagSearchText)})
        } else {
            return tags
        }
    }
    
    var body: some View {
        NewFlowLayout(alignment: .leading) {
            if object.tags.isEmpty {
                Text("No tags selected")
                    .font(.caption)
                    .foregroundStyle(.gray)
            } else {
                ForEach(object.tags) {tag in
                    Button {
                        object.removeTag(tag)
                    } label: {
                        Label(tag.name, systemImage: "xmark")
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
        .onAppear() {
            print("APPEAR")
            /*
            API.getTags(type: type) { result in
                switch result {
                case .success(let response):
                    LoadedTags = response.tags
                case .failure(let error):
                    print(error)
                }
            }\*/
        }
        
        if isSearchable {
            IconTextField("magnifyingglass", text: $tagSearchText, prompt: "Search")
        }

        List {
            ForEach(searchResults, id: \.self) {tag in
                HStack {
                    Text(tag.name)
                    Spacer()
                    Button {
                        object.addTag(tag)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    TagEditor(object: .constant(DrinkIngredient.Sample))
}
