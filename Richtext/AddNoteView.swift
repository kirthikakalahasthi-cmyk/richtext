import SwiftUI
import UIKit

/// The "Add a note" screen: header (back / title / Create), rich text body, formatting toolbar.
struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var controller = RichTextController()

    @State private var note = NSAttributedString(
        string: "",
        attributes: [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.label
        ]
    )

    /// Called when the user taps Create. Hand back the finished attributed string.
    var onCreate: (NSAttributedString) -> Void = { _ in }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            RichTextEditor(text: $note, placeholder: "Add a note") { textView in
                controller.textView = textView
                textView.becomeFirstResponder()
            }
            .frame(maxHeight: .infinity)

            FormattingToolbar(controller: controller)
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
    }

    private var header: some View {
        ZStack {
            Text("Add a note")
                .font(.headline)

            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.primary)
                }
                Spacer()
                Button { onCreate(note); dismiss() } label: {
                    Text("Create")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(Color.black))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    AddNoteView()
}
