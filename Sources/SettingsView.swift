import SwiftUI
import ServiceManagement

// MARK: - Settings View
struct SettingsView: View {
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled

    var body: some View {
        TabView {
            // ---- General Tab ----
            VStack(alignment: .leading, spacing: 20) {
                Text("通用设置")
                    .font(.title2)
                    .bold()

                Divider()

                Toggle(isOn: $launchAtLogin) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("开机自启动")
                            .font(.body)
                        Text("登录系统时自动启动便条贴")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onChange(of: launchAtLogin) { _, enabled in
                    setLaunchAtLogin(enabled)
                }
                .toggleStyle(.switch)

                Spacer()
            }
            .padding(24)
            .frame(width: 400, height: 200)
            .tabItem {
                Label("通用", systemImage: "gear")
            }
        }
    }

    // MARK: - Launch at Login

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("[Settings] 开机自启动设置失败: \(error.localizedDescription)")
            // Revert toggle on failure
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}

// MARK: - Settings Window Controller
final class SettingsWindowController {
    static let shared = SettingsWindowController()
    private var window: NSWindow?

    private init() {}

    func show() {
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate()
            return
        }

        let hostingView = NSHostingView(rootView: SettingsView())
        hostingView.frame = NSRect(x: 0, y: 0, width: 400, height: 200)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 260),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "便条贴设置"
        window.contentView = hostingView
        window.center()
        window.isReleasedWhenClosed = false

        window.makeKeyAndOrderFront(nil)
        NSApp.activate()

        self.window = window
    }
}
