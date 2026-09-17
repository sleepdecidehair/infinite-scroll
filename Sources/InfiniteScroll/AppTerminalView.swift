import AppKit
import SwiftTerm

/// App-owned terminal view.
///
/// - Finder files dragged onto the view (or pasted with Cmd+V) become
///   shell-escaped absolute paths, the way Terminal.app does it.
/// - The blinking caret steps aside while an input method is composing, so it
///   cannot cover the marked-text preview (see `syncCaretDuringComposition`).
final class AppTerminalView: LocalProcessTerminalView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerForDraggedTypes([.fileURL])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }

    // MARK: - IME composition caret

    override func setMarkedText(_ string: Any, selectedRange: NSRange, replacementRange: NSRange) {
        super.setMarkedText(string, selectedRange: selectedRange, replacementRange: replacementRange)
        syncCaretDuringComposition()
    }

    override func insertText(_ string: Any, replacementRange: NSRange) {
        super.insertText(string, replacementRange: replacementRange)
        syncCaretDuringComposition()
    }

    override func unmarkText() {
        super.unmarkText()
        syncCaretDuringComposition()
    }

    /// SwiftTerm shows the pinyin preview as a subview anchored at the caret,
    /// but it re-adds its own CaretView on top of that preview every time the
    /// running program brings the hardware cursor back, so the blinking block
    /// swallows the first character of the composition. Hide the caret while
    /// marked text exists; the underlined preview marks the insertion point.
    override func didAddSubview(_ subview: NSView) {
        super.didAddSubview(subview)
        if Self.isCaretView(subview), hasMarkedText() {
            subview.isHidden = true
        }
    }

    private func syncCaretDuringComposition() {
        guard let caret = subviews.first(where: { Self.isCaretView($0) }) else { return }
        caret.isHidden = hasMarkedText()
    }

    /// SwiftTerm keeps `CaretView` internal, so match its class name instead of
    /// its type.
    private static func isCaretView(_ view: NSView) -> Bool {
        String(describing: type(of: view)) == "CaretView"
    }

    // MARK: - File drops and paste

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        filePaths(from: sender.draggingPasteboard).isEmpty ? [] : .copy
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        filePaths(from: sender.draggingPasteboard).isEmpty ? [] : .copy
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let paths = filePaths(from: sender.draggingPasteboard)
        guard !paths.isEmpty else { return false }
        insert(ShellPathEscaping.joined(paths))
        return true
    }

    /// Finder puts both the file URL and a plain-text file name on the
    /// pasteboard, and SwiftTerm's paste only reads the name. Prefer the URL
    /// so Cmd+V matches what a drag inserts.
    override func paste(_ sender: Any) {
        let paths = filePaths(from: NSPasteboard.general)
        guard !paths.isEmpty else {
            super.paste(sender)
            return
        }
        insert(ShellPathEscaping.joined(paths))
    }

    /// Mirrors SwiftTerm's paste insertion so bracketed-paste-aware programs
    /// receive the path exactly like a normal Cmd+V.
    private func insert(_ text: String) {
        guard !text.isEmpty else { return }
        if terminal.bracketedPasteMode {
            send(data: EscapeSequences.bracketedPasteStart[0...])
        }
        send(txt: text)
        if terminal.bracketedPasteMode {
            send(data: EscapeSequences.bracketedPasteEnd[0...])
        }
    }

    private func filePaths(from pasteboard: NSPasteboard) -> [String] {
        let objects = pasteboard.readObjects(
            forClasses: [NSURL.self],
            options: [.urlReadingFileURLsOnly: true]
        )
        return (objects as? [URL])?.map(\.path) ?? []
    }
}
