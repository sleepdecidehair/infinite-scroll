import AppKit
import SwiftTerm

/// Terminal view that handles Finder files the way Terminal.app does: a drag
/// or a paste inserts their shell-escaped absolute paths instead of just the
/// display name.
final class PathDropTerminalView: LocalProcessTerminalView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerForDraggedTypes([.fileURL])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }

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
