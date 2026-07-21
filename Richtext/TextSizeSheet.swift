import SwiftUI

/// The three text-size choices offered by the "Select text size" bottom sheet.
enum TextSizeOption: CaseIterable, Identifiable {
    case heading1, heading2, normal

    var id: Self { self }

    var label: String {
        switch self {
        case .heading1: return "Heading 1"
        case .heading2: return "Heading 2"
        case .normal:   return "Normal text"
        }
    }

    var pointSize: CGFloat {
        switch self {
        case .heading1: return 28
        case .heading2: return 22
        case .normal:   return 17
        }
    }
}

/// Bottom sheet for choosing a text size, replacing the old popover menu to match the design.
struct TextSizeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: TextSizeOption
    let onSelect: (TextSizeOption) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Select text size")
                    .font(.headline)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.primary)
                }
            }
            .padding(.horizontal, 24)
            .frame(height: 40)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(TextSizeOption.allCases) { option in
                    Button {
                        selection = option
                        onSelect(option)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .semibold))
                                .opacity(selection == option ? 1 : 0)
                            Text(option.label)
                                .font(.system(size: option.pointSize))
                            Spacer()
                        }
                        .foregroundStyle(Color.primary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 24)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)

            Spacer(minLength: 0)
        }
        .presentationDetents([.height(260)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    TextSizeSheet(selection: .constant(.normal)) { _ in }
}
