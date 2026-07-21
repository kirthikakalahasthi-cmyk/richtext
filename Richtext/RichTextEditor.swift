import SwiftUI
import UIKit

/// A SwiftUI wrapper around `UITextView` that supports rich text (NSAttributedString) editing.
///
/// SwiftUI's built-in `TextEditor` does not expose per-run attributes (bold/italic/underline/
/// alignment/lists) across the iOS versions most apps still support, so a `UITextView` bridged
/// via `UIViewRepresentable` is the reliable native approach for a rich text formatter.
struct RichTextEditor: UIViewRepresentable {
    @Binding var text: NSAttributedString
    let placeholder: String
    /// Called once when the underlying text view exists, so a controller can hold a reference
    /// and issue formatting commands to it.
    let onReady: (UITextView) -> Void

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.delegate = context.coordinator
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        tv.autocorrectionType = .default
        tv.font = UIFont.systemFont(ofSize: 17)
        tv.textColor = .label
        tv.attributedText = text
        // Default style for freshly typed text in an empty editor.
        tv.typingAttributes = [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.label
        ]

        context.coordinator.attachPlaceholder(to: tv, text: placeholder)
        DispatchQueue.main.async { onReady(tv) }
        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        // Avoid clobbering the cursor while the user (or a format command) is editing.
        if !context.coordinator.isSyncingInternally, uiView.attributedText != text {
            let saved = uiView.selectedRange
            uiView.attributedText = text
            uiView.selectedRange = saved
        }
        context.coordinator.refreshPlaceholder(in: uiView)
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        var isSyncingInternally = false
        private let placeholderLabel = UILabel()

        init(_ parent: RichTextEditor) { self.parent = parent }

        func textViewDidChange(_ textView: UITextView) {
            isSyncingInternally = true
            parent.text = textView.attributedText
            isSyncingInternally = false
            refreshPlaceholder(in: textView)
        }

        func attachPlaceholder(to textView: UITextView, text: String) {
            placeholderLabel.text = text
            placeholderLabel.font = UIFont.systemFont(ofSize: 17)
            placeholderLabel.textColor = .placeholderText
            placeholderLabel.numberOfLines = 0
            placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
            textView.addSubview(placeholderLabel)
            NSLayoutConstraint.activate([
                placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 12),
                placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 20),
                placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -20)
            ])
            refreshPlaceholder(in: textView)
        }

        func refreshPlaceholder(in textView: UITextView) {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
}

// MARK: - Formatting commands

extension UITextView {

    func toggleBold()   { toggleSymbolicTrait(.traitBold) }
    func toggleItalic() { toggleSymbolicTrait(.traitItalic) }

    /// Toggles a font trait across the selection. With no selection, it changes `typingAttributes`
    /// so the next characters typed adopt the trait.
    private func toggleSymbolicTrait(_ trait: UIFontDescriptor.SymbolicTraits) {
        let range = selectedRange
        if range.length == 0 {
            let current = (typingAttributes[.font] as? UIFont) ?? UIFont.systemFont(ofSize: 17)
            let has = current.fontDescriptor.symbolicTraits.contains(trait)
            typingAttributes[.font] = fontByToggling(current, trait: trait, enabled: !has)
            return
        }

        let mutable = NSMutableAttributedString(attributedString: attributedText)
        // If every run in the selection already has the trait, we remove it; otherwise we add it.
        var allHaveTrait = true
        mutable.enumerateAttribute(.font, in: range, options: []) { value, _, _ in
            let f = (value as? UIFont) ?? UIFont.systemFont(ofSize: 17)
            if !f.fontDescriptor.symbolicTraits.contains(trait) { allHaveTrait = false }
        }
        mutable.enumerateAttribute(.font, in: range, options: []) { value, subRange, _ in
            let f = (value as? UIFont) ?? UIFont.systemFont(ofSize: 17)
            let newFont = self.fontByToggling(f, trait: trait, enabled: !allHaveTrait)
            mutable.addAttribute(.font, value: newFont, range: subRange)
        }
        applyPreservingSelection(mutable)
    }

    private func fontByToggling(_ base: UIFont,
                                trait: UIFontDescriptor.SymbolicTraits,
                                enabled: Bool) -> UIFont {
        var traits = base.fontDescriptor.symbolicTraits
        if enabled { traits.insert(trait) } else { traits.remove(trait) }
        if let descriptor = base.fontDescriptor.withSymbolicTraits(traits) {
            return UIFont(descriptor: descriptor, size: base.pointSize)
        }
        return base
    }

    func toggleUnderline() {
        let range = selectedRange
        if range.length == 0 {
            let current = (typingAttributes[.underlineStyle] as? Int) ?? 0
            typingAttributes[.underlineStyle] = current == 0 ? NSUnderlineStyle.single.rawValue : 0
            return
        }
        let mutable = NSMutableAttributedString(attributedString: attributedText)
        var allUnderlined = true
        mutable.enumerateAttribute(.underlineStyle, in: range, options: []) { value, _, _ in
            if ((value as? Int) ?? 0) == 0 { allUnderlined = false }
        }
        let newValue = allUnderlined ? 0 : NSUnderlineStyle.single.rawValue
        mutable.addAttribute(.underlineStyle, value: newValue, range: range)
        applyPreservingSelection(mutable)
    }

    func setFontSize(_ size: CGFloat) {
        let range = selectedRange
        if range.length == 0 {
            let current = (typingAttributes[.font] as? UIFont) ?? UIFont.systemFont(ofSize: 17)
            typingAttributes[.font] = UIFont(descriptor: current.fontDescriptor, size: size)
            return
        }
        let mutable = NSMutableAttributedString(attributedString: attributedText)
        mutable.enumerateAttribute(.font, in: range, options: []) { value, subRange, _ in
            let f = (value as? UIFont) ?? UIFont.systemFont(ofSize: 17)
            mutable.addAttribute(.font, value: UIFont(descriptor: f.fontDescriptor, size: size), range: subRange)
        }
        applyPreservingSelection(mutable)
    }

    func setAlignment(_ alignment: NSTextAlignment) {
        if attributedText.length == 0 {
            let para = NSMutableParagraphStyle(); para.alignment = alignment
            typingAttributes[.paragraphStyle] = para
            return
        }
        let range = (attributedText.string as NSString).paragraphRange(for: selectedRange)
        let mutable = NSMutableAttributedString(attributedString: attributedText)
        mutable.enumerateAttribute(.paragraphStyle, in: range, options: []) { value, subRange, _ in
            let para = (value as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle
                ?? NSMutableParagraphStyle()
            para.alignment = alignment
            mutable.addAttribute(.paragraphStyle, value: para, range: subRange)
        }
        applyPreservingSelection(mutable)
        let para = NSMutableParagraphStyle(); para.alignment = alignment
        typingAttributes[.paragraphStyle] = para
    }

    /// Adds or removes a bullet prefix on every selected paragraph.
    func toggleBulletList() {
        let bullet = "\u{2022}\t"
        let full = (attributedText.string as NSString).paragraphRange(for: selectedRange)

        var lineStarts: [Int] = []
        (attributedText.string as NSString).enumerateSubstrings(in: full, options: .byParagraphs) { _, sub, _, _ in
            lineStarts.append(sub.location)
        }

        let mutable = NSMutableAttributedString(attributedString: attributedText)
        let firstLineRange = (mutable.string as NSString)
            .paragraphRange(for: NSRange(location: full.location, length: 0))
        let firstLine = (mutable.string as NSString).substring(with: firstLineRange)
        let adding = !firstLine.hasPrefix(bullet)

        // Reverse order keeps earlier offsets valid as the string length changes.
        for start in lineStarts.sorted(by: >) {
            let lineRange = (mutable.string as NSString)
                .paragraphRange(for: NSRange(location: start, length: 0))
            let line = (mutable.string as NSString).substring(with: lineRange)
            if adding {
                if !line.hasPrefix(bullet) {
                    mutable.insert(NSAttributedString(string: bullet, attributes: typingAttributes), at: start)
                }
            } else if line.hasPrefix(bullet) {
                mutable.replaceCharacters(in: NSRange(location: start, length: (bullet as NSString).length), with: "")
            }
        }
        attributedText = mutable
        delegate?.textViewDidChange?(self)
    }

    /// Programmatic changes to `attributedText` reset the caret and do not fire the delegate,
    /// so we restore the selection and notify manually to keep the SwiftUI binding in sync.
    private func applyPreservingSelection(_ new: NSAttributedString) {
        let saved = selectedRange
        attributedText = new
        selectedRange = saved
        delegate?.textViewDidChange?(self)
    }
}
