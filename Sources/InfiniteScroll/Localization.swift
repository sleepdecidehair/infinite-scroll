import SwiftUI

/// Language choice for the app interface. `.system` follows the macOS
/// preferred language, the other cases let Settings override it.
enum AppLanguage: String, CaseIterable, Codable {
    case system
    case chinese
    case english

    var resolved: ResolvedLanguage {
        switch self {
        case .chinese: return .chinese
        case .english: return .english
        case .system:
            let preferred = Locale.preferredLanguages.first ?? "en"
            return preferred.hasPrefix("zh") ? .chinese : .english
        }
    }
}

enum ResolvedLanguage {
    case chinese
    case english
}

/// All user-facing strings, resolved for one language. SwiftUI views read the
/// struct from the environment so changing the language re-renders them; code
/// without an environment (AppKit alerts) goes through `L10n.strings`.
struct Strings {
    let language: ResolvedLanguage

    init(language: ResolvedLanguage) {
        self.language = language
    }

    private func pick(_ english: String, _ chinese: String) -> String {
        language == .chinese ? chinese : english
    }

    // MARK: Menu commands

    var menuCloseCell: String { pick("Close Cell", "关闭单元格") }
    var menuDuplicateCell: String { pick("Duplicate Cell", "复制单元格") }
    var menuNewRowAbove: String { pick("New Row Above", "在上方新建行") }
    var menuNewRowBelow: String { pick("New Row Below", "在下方新建行") }
    var menuRenameCurrentRow: String { pick("Rename Current Row", "重命名当前行") }
    var menuFindInWorkspace: String { pick("Find in Workspace…", "在工作区中查找…") }
    var menuCopyCLIPrompt: String { pick("Copy CLI Prompt", "拷贝 CLI 提示词") }
    var menuKeyboardShortcuts: String { pick("Keyboard Shortcuts", "键盘快捷键") }
    var menuZoomIn: String { pick("Zoom In", "放大") }
    var menuZoomOut: String { pick("Zoom Out", "缩小") }
    var menuFocusRowAbove: String { pick("Focus Row Above", "聚焦上一行") }
    var menuFocusRowBelow: String { pick("Focus Row Below", "聚焦下一行") }
    var menuFocusLeft: String { pick("Focus Left", "聚焦左侧") }
    var menuFocusRight: String { pick("Focus Right", "聚焦右侧") }

    // MARK: Workspace

    var showAgentQueue: String { pick("Show Agent Queue", "显示 Agent 队列") }
    var noTerminalsOpen: String { pick("No terminals open", "没有打开的终端") }
    var newTerminal: String { pick("New Terminal", "新建终端") }
    var newTerminalHint: String { pick("or press ⌘ ⇧ ↓", "或按 ⌘ ⇧ ↓") }

    // MARK: Row chrome

    var renameRowHelp: String { pick("Rename row (⌘⇧R)", "重命名行（⌘⇧R）") }
    var renameRow: String { pick("Rename row", "重命名行") }
    var newRowBadge: String { pick("NEW", "新增") }
    var toggleNotes: String { pick("Toggle notes", "显示/隐藏笔记") }
    var closeRow: String { pick("Close row", "关闭行") }

    /// Display form of a row title. Generated titles stay in English in the
    /// model (they are persisted and shown by the CLI), so translate them for
    /// display only. User-chosen names are shown as typed.
    func rowTitle(_ title: String, isMaster: Bool) -> String {
        guard language == .chinese else { return title }
        if isMaster && title == PanelModel.defaultMasterTitle {
            return "主控行 · 第 0 行"
        }
        if let index = PanelModel.generatedRowIndex(of: title) {
            return "第 \(index) 行"
        }
        return title
    }

    // MARK: Workspace search

    var findInWorkspaceTitle: String { pick("Find in Workspace", "在工作区中查找") }
    var closeWorkspaceSearch: String { pick("Close workspace search", "关闭工作区搜索") }
    var searchHint: String {
        pick(
            "Search row names, folders, and notes. Press Return to jump to the first result.",
            "搜索行名称、文件夹和笔记；按 Return 跳到第一个结果。"
        )
    }
    var noWorkspaceMatches: String { pick("No workspace matches", "没有匹配结果") }
    var searchPlaceholder: String { pick("Search rows, folders, and notes", "搜索行、文件夹和笔记") }

    func searchKindLabel(_ kind: WorkspaceSearchMatchKind) -> String {
        switch kind {
        case .title: return pick("Row name", "行名称")
        case .directory: return pick("Folder", "文件夹")
        case .notes: return pick("Notes", "笔记")
        }
    }

    var masterRowDetail: String { pick("Master row", "主控行") }
    func rowDetail(index: Int) -> String { pick("Row \(index)", "第 \(index) 行") }

    // MARK: Help overlay

    var helpTitle: String { pick("Keyboard Shortcuts", "键盘快捷键") }
    var helpCloseCurrentCell: String { pick("Close current cell", "关闭当前单元格") }
    var helpDuplicateCell: String { pick("Duplicate current cell", "复制当前单元格") }
    var helpNewRowAbove: String { pick("New row above", "在上方新建行") }
    var helpNewRowBelow: String { pick("New row below; terminal if empty", "在下方新建行；为空时新建终端") }
    var helpRenameRow: String { pick("Rename current row", "重命名当前行") }
    var helpZoomIn: String { pick("Zoom in", "放大") }
    var helpZoomOut: String { pick("Zoom out", "缩小") }
    var helpOpenSettings: String { pick("Open settings", "打开设置") }
    var helpFocusRowAbove: String { pick("Focus row above", "聚焦上一行") }
    var helpFocusRowBelow: String { pick("Focus row below", "聚焦下一行") }
    var helpFocusLeft: String { pick("Focus left", "聚焦左侧") }
    var helpFocusRight: String { pick("Focus right", "聚焦右侧") }
    var helpScrollRows: String { pick("Scroll between rows (speed in Settings)", "在行之间滚动（速度可在设置中调整）") }
    var helpFind: String { pick("Find rows, folders, and notes", "查找行、文件夹和笔记") }
    var helpShiftEnter: String { pick("Send newline in terminal", "在终端中发送换行") }
    var helpDeleteLine: String { pick("Delete to start of line (notes)", "删除到行首（笔记）") }
    var helpToggle: String { pick("Toggle this help", "显示/隐藏本帮助") }

    // MARK: Agent queue

    var agentQueue: String { pick("Agent Queue", "Agent 队列") }
    var settings: String { pick("Settings", "设置") }
    var backToAgentQueue: String { pick("Back to Agent Queue", "返回 Agent 队列") }
    var hideAgentQueue: String { pick("Hide Agent Queue", "隐藏 Agent 队列") }
    var agentActivity: String { pick("AGENT ACTIVITY", "AGENT 活动") }
    var noAgentsDetected: String { pick("No agents detected in this workspace.", "未检测到 Agent。") }
    var startAgentHint: String {
        pick(
            "Start an agent in any terminal and it will appear here automatically.",
            "在任意终端中启动 Agent，它会自动出现在这里。"
        )
    }
    var pathUnavailable: String { pick("Path unavailable", "路径不可用") }
    var focusTerminal: String { pick("Focus terminal", "聚焦终端") }
    var copyPath: String { pick("Copy Path", "拷贝路径") }
    var agentStatus: String { pick("Agent status", "Agent 状态") }
    var agentRowHint: String {
        pick(
            "Focuses the associated terminal. Open the context menu to copy its path.",
            "聚焦关联的终端；打开上下文菜单可拷贝路径。"
        )
    }
    var helpPath: String { pick("Path: ", "路径：") }
    var helpProvider: String { pick("Provider: ", "提供方：") }
    var helpStatus: String { pick("Status: ", "状态：") }
    var helpLastObserved: String { pick("Last observed: ", "最近活动：") }
    var helpDetection: String { pick("Detection: ", "检测方式：") }
    var helpClickToFocus: String { pick("Click to focus the terminal.", "点击可聚焦终端。") }

    func detectedAgent(provider: String) -> String {
        pick("Detected \(provider) agent", "检测到 \(provider) Agent")
    }

    func agentRunState(_ state: AgentRunState) -> String {
        switch state {
        case .starting: return pick("Starting", "启动中")
        case .working: return pick("Running", "运行中")
        case .waitingForUser: return pick("Asking", "询问中")
        case .waitingForApproval: return pick("Approval", "等待批准")
        case .idle: return pick("Idle", "空闲")
        case .stopped: return pick("Stopped", "已停止")
        case .failed: return pick("Failed", "失败")
        case .unknown: return pick("Unknown", "未知")
        }
    }

    func detectionConfidence(_ confidence: AgentDetectionConfidence) -> String {
        switch confidence {
        case .confirmed: return pick("confirmed", "已确认")
        case .likely: return pick("likely", "可能")
        case .unknown: return pick("unknown", "未知")
        }
    }

    // MARK: Agent status messages

    func agentLaunching(_ provider: String) -> String {
        pick("Launching \(provider)", "正在启动 \(provider)")
    }

    func agentStarting(_ provider: String) -> String {
        pick("Starting \(provider)", "正在启动 \(provider)")
    }

    func agentWaitingForApproval(_ provider: String) -> String {
        pick("\(provider) is waiting for approval", "\(provider) 正在等待批准")
    }

    func agentAskingForInput(_ provider: String) -> String {
        pick("\(provider) is asking for input", "\(provider) 正在请求输入")
    }

    func agentRunning(_ provider: String) -> String {
        pick("\(provider) is running", "\(provider) 正在运行")
    }

    var agentStillRunningBeforeRetry: String {
        pick("Agent process is still running; focus it before retrying", "Agent 进程仍在运行；请先聚焦再重试")
    }
    var agentWaitingForInput: String { pick("Waiting for input or a dependency", "等待输入或依赖") }
    var agentBlockedNeedsReview: String { pick("Blocked — needs review", "受阻 — 需要检查") }
    var agentMarkedComplete: String { pick("Marked complete", "已标记完成") }
    var agentMarkedFailed: String { pick("Marked failed", "已标记失败") }
    var agentCancelled: String { pick("Cancelled", "已取消") }
    var agentCommandSent: String { pick("Command sent; waiting for process", "命令已发送；等待进程启动") }
    var agentProcessGone: String { pick("Agent process is no longer present", "Agent 进程已不存在") }
    var agentProcessEndedConfirm: String {
        pick(
            "Agent process ended; confirm the result before completing",
            "Agent 进程已结束；请确认结果后再标记完成"
        )
    }

    // MARK: Settings

    var settingsLanguage: String { pick("Language", "语言") }
    var settingsInterfaceLanguage: String { pick("Interface Language", "界面语言") }
    var settingsLanguageSystem: String { pick("Follow System", "跟随系统") }
    var settingsAppearance: String { pick("Appearance", "外观") }
    var settingsFont: String { pick("Font", "字体") }
    func settingsFontSize(_ points: Int) -> String { pick("Size: \(points)pt", "字号：\(points)pt") }
    var settingsTerminal: String { pick("Terminal", "终端") }
    var settingsScrollback: String { pick("Scrollback", "回滚行数") }
    func settingsScrollbackLines(_ lines: Int) -> String {
        pick("\(lines.formatted()) lines", "\(lines.formatted()) 行")
    }
    var settingsScrollbackNote: String {
        pick(
            "Applies to every terminal and to the tmux sessions backing them. Larger values use more memory per terminal.",
            "作用于所有终端及其背后的 tmux 会话；数值越大，每个终端占用的内存越多。"
        )
    }
    var settingsLayout: String { pick("Layout", "布局") }
    func settingsRowHeight(_ pixels: Int) -> String { pick("Row height: \(pixels)px", "行高：\(pixels)px") }
    var settingsNavigation: String { pick("Navigation", "导航") }
    var settingsScrollSpeed: String { pick("Workspace scroll speed", "工作区滚动速度") }
    var settingsScrollSpeedNote: String {
        pick(
            "Applies only when holding Command while scrolling between rows.",
            "仅在按住 Command 键在行之间滚动时生效。"
        )
    }
    var settingsShellCommand: String { pick("Shell command", "命令行工具") }
    func settingsInstalledAt(_ path: String) -> String { pick("Installed at \(path)", "已安装到 \(path)") }
    var settingsNotInstalled: String { pick("Not installed", "未安装") }
    var settingsCLINote: String {
        pick(
            "Lets AI agents and scripts read and manipulate cells from a terminal. Run 'infinite-scroll --help' to see commands.",
            "让 AI agent 和脚本可以从终端读取并操作单元格；运行 'infinite-scroll --help' 查看可用命令。"
        )
    }
    var settingsUninstall: String { pick("Uninstall", "卸载") }
    var settingsInstall: String { pick("Install Shell Command", "安装命令行工具") }
    func settingsUninstallFailed(_ path: String) -> String {
        pick("Uninstall failed. Check permissions for \(path).", "卸载失败，请检查 \(path) 的权限。")
    }
    func settingsInstallFailed(_ path: String) -> String {
        pick("Install failed. Check permissions for \(path).", "安装失败，请检查 \(path) 的权限。")
    }

    // MARK: Alerts

    var renameRowPlaceholder: String { pick("Row name", "行名称") }
    var renameMasterRowTitle: String { pick("Rename Master Row", "重命名主控行") }
    var renameRowTitle: String { pick("Rename Row", "重命名行") }
    var renameRowMessage: String { pick("Choose a name for this row.", "为此行输入名称。") }
    var rename: String { pick("Rename", "重命名") }
    var cancel: String { pick("Cancel", "取消") }

    var cliInstallPromptTitle: String { pick("Install 'infinite-scroll' command?", "安装 \"infinite-scroll\" 命令行工具？") }
    var cliInstallPromptMessage: String {
        pick(
            """
            Install a shell command at /usr/local/bin/infinite-scroll so AI agents \
            (or you) can read and manipulate cells from the terminal.

            You can install or uninstall this later from Settings.
            """,
            """
            在 /usr/local/bin/infinite-scroll 安装命令行工具，让 AI agent（或你）\
            可以从终端读取并操作单元格。

            之后可以随时在设置中安装或卸载。
            """
        )
    }
    var cliInstall: String { pick("Install", "安装") }
    var cliNotNow: String { pick("Not Now", "暂不") }
    var cliInstallFailedTitle: String { pick("Install failed", "安装失败") }
    var cliInstallFailedMessage: String {
        pick(
            "Could not install the shell command. You can try again from Settings.",
            "无法安装命令行工具，可在设置中重试。"
        )
    }
}

/// Process-wide language for code paths that have no SwiftUI environment, such
/// as AppKit alerts. `PanelStore` keeps this in sync with the user's choice.
enum L10n {
    private(set) static var current: ResolvedLanguage = .english

    static var strings: Strings { Strings(language: current) }

    static func update(_ language: ResolvedLanguage) {
        current = language
    }
}

private struct StringsEnvironmentKey: EnvironmentKey {
    static let defaultValue = Strings(language: .english)
}

extension EnvironmentValues {
    var strings: Strings {
        get { self[StringsEnvironmentKey.self] }
        set { self[StringsEnvironmentKey.self] = newValue }
    }
}
