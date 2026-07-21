import SwiftUI

/// The landing screen: two entry points into the note editor — a full-page push
/// and a full-height bottom sheet.
struct LandingView: View {
    @State private var showEditorSheet = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 16) {
                NavigationLink {
                    AddNoteView()
                } label: {
                    ctaLabel("Open full page")
                }

                Button {
                    showEditorSheet = true
                } label: {
                    ctaLabel("Open as bottom sheet")
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showEditorSheet) {
            AddNoteView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private func ctaLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Capsule().fill(Color.black))
    }
}

#Preview {
    NavigationStack {
        LandingView()
    }
}
