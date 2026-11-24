import SwiftUI

struct LaunchView: View {
    @State private var showsSpinner = false

    var body: some View {
        Image(.launchWordmark)
            .overlay(alignment: .bottom) {
                if showsSpinner {
                    ProgressView()
                        .offset(y: Layout.spinnerOffset)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .ignoresSafeArea()
            .task {
                guard (try? await Task.sleep(for: Layout.spinnerDelay)) != nil else { return }
                withAnimation {
                    showsSpinner = true
                }
            }
    }

    private enum Layout {
        static let spinnerOffset: CGFloat = 40
        static let spinnerDelay: Duration = .seconds(1)
    }
}

#Preview {
    LaunchView()
}
