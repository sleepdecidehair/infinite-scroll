import SwiftUI

@main
struct InfiniteScrollApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var store = PanelStore()

    var body: some Scene {
        let strings = Strings(language: store.appLanguage.resolved)

        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environment(\.strings, strings)
                .frame(minWidth: 640, minHeight: 420)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 1280, height: 800)
        .commands {
            // Single-window app: a second window would run its own agent
            // monitor and detach the first window's tmux clients.
            CommandGroup(replacing: .newItem) { }

            // Cmd+W: close current cell
            CommandGroup(replacing: .saveItem) {
                Button(strings.menuCloseCell) {
                    store.closeCurrentCell()
                }
                .keyboardShortcut("w", modifiers: .command)
            }
            CommandGroup(after: .newItem) {
                // Cmd+D: duplicate current cell
                Button(strings.menuDuplicateCell) {
                    store.duplicateCurrentCell()
                }
                .keyboardShortcut("d", modifiers: .command)

                // Cmd+Shift+Up: new row above
                Button(strings.menuNewRowAbove) {
                    store.addPanelAbove()
                }
                .keyboardShortcut(.upArrow, modifiers: [.command, .shift])

                // Cmd+Shift+Down: new row below
                Button(strings.menuNewRowBelow) {
                    store.addPanel()
                }
                .keyboardShortcut(.downArrow, modifiers: [.command, .shift])

                Button(strings.menuRenameCurrentRow) {
                    store.renameCurrentRow()
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
            }
            CommandGroup(after: .pasteboard) {
                Divider()
                Button(strings.menuFindInWorkspace) {
                    store.toggleWorkspaceSearch()
                }
                .keyboardShortcut("f", modifiers: .command)

                Divider()
                Button(strings.menuCopyCLIPrompt) {
                    CLIPromptCopier.copyToPasteboard()
                }
            }
            CommandGroup(replacing: .help) {
                Button(strings.menuKeyboardShortcuts) {
                    store.showHelp.toggle()
                }
                .keyboardShortcut("/", modifiers: .command)
            }
            CommandGroup(after: .toolbar) {
                Button(strings.menuZoomIn) {
                    store.zoomIn()
                }
                .keyboardShortcut("=", modifiers: .command)
                Button(strings.menuZoomOut) {
                    store.zoomOut()
                }
                .keyboardShortcut("-", modifiers: .command)

                Divider()

                Button(strings.menuFocusRowAbove) {
                    store.focusUp()
                }
                .keyboardShortcut(.upArrow, modifiers: .command)
                Button(strings.menuFocusRowBelow) {
                    store.focusDown()
                }
                .keyboardShortcut(.downArrow, modifiers: .command)
                Button(strings.menuFocusLeft) {
                    store.focusLeft()
                }
                .keyboardShortcut(.leftArrow, modifiers: .command)
                Button(strings.menuFocusRight) {
                    store.focusRight()
                }
                .keyboardShortcut(.rightArrow, modifiers: .command)
            }
        }

        Settings {
            SettingsView()
                .environmentObject(store)
                .environment(\.strings, strings)
        }
    }
}
