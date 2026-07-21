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
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
            }
            .padding(.leading, 24)
            .padding(.trailing, 8)
            .padding(.top, 8)
            .frame(height: 48)

            VStack(alignment: .leading, spacing: 4) {
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
                            Spacer(minLength: 0)
                        }
                        .foregroundStyle(Color.primary)
                        .padding(.vertical, 10)
                        .padding(.leading, 24)
                        .padding(.trailing, 12)
                        .frame(minHeight: 40)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 16)
        }
        .presentationDetents([.height(240)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    TextSizeSheet(selection: .constant(.normal)) { _ in }
}
