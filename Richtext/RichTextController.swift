import SwiftUI
import UIKit
import Combine
 
/// Shared reference between the editor and the toolbar. The toolbar calls these methods;
/// the editor supplies the live `UITextView`.
final class RichTextController: ObservableObject {
    weak var textView: UITextView?
 
    func bold()      { textView?.toggleBold() }
    func italic()    { textView?.toggleItalic() }
    func underline() { textView?.toggleUnderline() }
 
    func alignLeft()   { textView?.setAlignment(.left) }
    func alignCenter() { textView?.setAlignment(.center) }
    func alignRight()  { textView?.setAlignment(.right) }
 
    func bulletList()  { textView?.toggleBulletList() }
    func fontSize(_ size: CGFloat) { textView?.setFontSize(size) }
}
