import Foundation

/// Backslash-escapes a POSIX path the way Terminal.app does when a file is
/// dropped into a window, so the result can be pasted straight into a shell.
enum ShellPathEscaping {
    /// Terminal.app escapes these ASCII characters and leaves alphanumerics
    /// plus `+ - . @ ^ _` alone. Backslash is added on top of that set: a
    /// filename may legally contain one, and leaving it raw would swallow the
    /// next character on the command line.
    private static let escapedCharacters: Set<Character> = [
        " ", "!", "\"", "#", "$", "%", "&", "'", "(", ")", "*", ",", ":", ";",
        "<", "=", ">", "?", "[", "]", "\\", "`", "{", "|", "}", "~",
    ]

    /// A single path with shell-significant characters backslash-escaped.
    static func escaped(_ path: String) -> String {
        var result = ""
        result.reserveCapacity(path.count)
        for character in path {
            if escapedCharacters.contains(character) {
                result.append("\\")
            }
            result.append(character)
        }
        return result
    }

    /// Space-joined escaped paths for one or more files.
    static func joined(_ paths: [String]) -> String {
        paths.map(escaped).joined(separator: " ")
    }
}
