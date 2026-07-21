import SwiftUI

/// The bottom formatting bar: text size, B / I / U, alignment, and bullet list —
/// grouped by thin dividers as in the design.
struct FormattingToolbar: View {
    @ObservedObject var controller: RichTextController
    @State private var showTextSizeSheet = false
    @State private var selectedTextSize: TextSizeOption = .normal

    var body: some View {
        HStack(spacing: 0) {
            Button { showTextSizeSheet = true } label: {
                icon("textformat.size")
            }
            .sheet(isPresented: $showTextSizeSheet) {
                TextSizeSheet(selection: $selectedTextSize) { option in
                    controller.fontSize(option.pointSize)
                }
            }

            divider

            button("bold")      { controller.bold() }
            button("italic")    { controller.italic() }
            button("underline") { controller.underline() }

            divider

            button("text.alignleft")   { controller.alignLeft() }
            button("text.aligncenter") { controller.alignCenter() }
            button("text.alignright")  { controller.alignRight() }

            divider

            button("list.bullet") { controller.bulletList() }
        }
        .padding(.horizontal, 8)
        .frame(height: 48)
        .background(Color(.systemGray6))
        .overlay(Divider(), alignment: .top)
    }

    private func button(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) { icon(systemName) }
    }

    private func icon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 17))
            .foregroundStyle(Color.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .contentShape(Rectangle())
    }

    private var divider: some View {
        Divider().frame(height: 22).padding(.horizontal, 4)
    }
}
