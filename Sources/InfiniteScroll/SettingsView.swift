import AppKit
import SwiftUI

struct SettingsView: View {
    /// Draws the same form without the fixed window frame when it is hosted in
    /// the right sidebar instead of the Settings scene.
    var embedded: Bool = false
    @EnvironmentObject var store: PanelStore
    @Environment(\.strings) private var strings
    @State private var cliInstalled: Bool = CLIInstaller.isInstalled()
    @State private var cliBusy: Bool = false
    @State private var cliError: String?

    var body: some View {
        Form {
            Section(strings.settingsLanguage) {
                Picker(strings.settingsInterfaceLanguage, selection: $store.appLanguage) {
                    Text(strings.settingsLanguageSystem).tag(AppLanguage.system)
                    Text("中文").tag(AppLanguage.chinese)
                    Text("English").tag(AppLanguage.english)
                }
            }

            Section(strings.settingsAppearance) {
                Picker(strings.settingsFont, selection: $store.fontName) {
                    ForEach(PanelStore.availableMonospacedFonts, id: \.self) { name in
                        Text(name)
                            .font(.custom(name, size: 13))
                            .tag(name)
                    }
                }

                Stepper(value: $store.fontSize, in: 8...32, step: 1) {
                    Text(strings.settingsFontSize(Int(store.fontSize)))
                }
            }

            Section(strings.settingsTerminal) {
                Picker(strings.settingsScrollback, selection: $store.scrollbackLimit) {
                    ForEach(TmuxManager.historyLimitOptions, id: \.self) { limit in
                        Text(strings.settingsScrollbackLines(limit)).tag(limit)
                    }
                }

                Text(strings.settingsScrollbackNote)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Section(strings.settingsLayout) {
                Stepper(
                    value: $store.rowHeight,
                    in: PanelStore.minRowHeight...PanelStore.maxRowHeight,
                    step: 25
                ) {
                    Text(strings.settingsRowHeight(Int(store.rowHeight)))
                }

                Slider(
                    value: $store.rowHeight,
                    in: PanelStore.minRowHeight...PanelStore.maxRowHeight,
                    step: 25
                )
            }

            Section(strings.settingsNavigation) {
                HStack {
                    Text(strings.settingsScrollSpeed)
                    Spacer()
                    Text("\(Int((store.commandScrollSpeed * 100).rounded()))%")
                        .foregroundColor(.secondary)
                }

                Slider(
                    value: $store.commandScrollSpeed,
                    in: PanelStore.minCommandScrollSpeed...PanelStore.maxCommandScrollSpeed,
                    step: 0.25
                )

                Text(strings.settingsScrollSpeedNote)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Section(strings.settingsShellCommand) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(
                            cliInstalled
                                ? strings.settingsInstalledAt(CLIInstaller.installTarget)
                                : strings.settingsNotInstalled
                        )
                        .font(.system(size: 12))
                        Text(strings.settingsCLINote)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        if let cliError {
                            Text(cliError)
                                .font(.system(size: 11))
                                .foregroundColor(Theme.closeButton)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    Spacer()
                    if cliInstalled {
                        Button(strings.settingsUninstall) {
                            cliBusy = true
                            cliError = nil
                            DispatchQueue.global(qos: .userInitiated).async {
                                let ok = CLIInstaller.uninstall()
                                DispatchQueue.main.async {
                                    cliInstalled = CLIInstaller.isInstalled()
                                    if !ok {
                                        cliError = strings.settingsUninstallFailed(CLIInstaller.installTarget)
                                    }
                                    cliBusy = false
                                }
                            }
                        }
                        .disabled(cliBusy)
                    } else {
                        Button(strings.settingsInstall) {
                            cliBusy = true
                            cliError = nil
                            DispatchQueue.global(qos: .userInitiated).async {
                                let ok = CLIInstaller.install()
                                DispatchQueue.main.async {
                                    cliInstalled = CLIInstaller.isInstalled()
                                    if !ok {
                                        cliError = strings.settingsInstallFailed(CLIInstaller.installTarget)
                                    }
                                    cliBusy = false
                                }
                            }
                        }
                        .disabled(cliBusy)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: embedded ? nil : 480, height: embedded ? nil : 620)
        .scrollContentBackground(embedded ? .hidden : .automatic)
        .background(embedded ? Theme.panelBackground : Color.clear)
        .onAppear { cliInstalled = CLIInstaller.isInstalled() }
    }
}
