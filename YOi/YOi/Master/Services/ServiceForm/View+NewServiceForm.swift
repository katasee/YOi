import SwiftUI

extension View {
    func newServiceForm(
        _ form: Binding<ServiceFormViewModel?>,
        onSaved: @escaping (Service) -> Void
    ) -> some View {
        fullScreenCover(item: form) { viewModel in
            ServiceFormPopup(viewModel: viewModel, blursBackground: true) {
                if let service = viewModel.savedService {
                    onSaved(service)
                }

                withoutPresentationAnimation {
                    form.wrappedValue = nil
                }
            }
            .presentationBackground(.clear)
        }
    }
}
