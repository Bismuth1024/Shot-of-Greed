import SwiftUI

struct OptionalTextField: View {
    let placeholder: String
    @Binding var text: String?
    
    init(_ placeholder: String, text: Binding<String?>) {
        self.placeholder = placeholder
        self._text = text
    }

    var body: some View {
        TextField(placeholder, text: Binding(
            get: { text ?? "" },
            set: { newValue in
                if newValue.isEmpty {
                    text = nil
                } else {
                    text = newValue
                }
            }
        ))
    }
}
