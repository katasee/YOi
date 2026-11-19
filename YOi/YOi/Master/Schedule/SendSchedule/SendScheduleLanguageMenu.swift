import SwiftUI

struct SendScheduleLanguageMenu: View {
    @Binding var language: MessageLanguage

    var body: some View {
        Menu {
            Picker(selection: $language) {
                ForEach(MessageLanguage.allCases) { language in
                    Text(verbatim: language.nativeName)
                        .tag(language)
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.inline)
        } label: {
            RoundIconLabel(systemImage: "globe", size: .small)
        }
    }
}

#Preview {
    @Previewable @State var language = MessageLanguage.uk

    SendScheduleLanguageMenu(language: $language)
        .padding()
        .background(Color.background)
}
