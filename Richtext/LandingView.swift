import SwiftUI

/// The landing screen: a single "Open richtext" button that pushes the note editor.
struct LandingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            NavigationLink {
                AddNoteView()
            } label: {
                Text("Open richtext")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.black))
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        LandingView()
    }
}
