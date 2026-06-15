import SwiftUI
import AppKit

// MARK: - App Delegate
final class AppDelegate: NSObject, NSApplicationDelegate {

    // Hold strong references to window controllers so they aren't deallocated
    private var windowControllers: [UUID: StickyNoteWindowController] = [:]
    private let store = NoteStore.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Build main menu first
        buildMainMenu()

        // Restore saved notes
        for note in store.notes {
            openWindow(for: note)
        }

        // If no notes exist, create a default one
        if store.notes.isEmpty {
            newNote(nil)
        }
    }

    func applicationShouldHandleReopen(
        _ sender: NSApplication,
        hasVisibleWindows flag: Bool
    ) -> Bool {
        if !flag || windowControllers.values.allSatisfy({ !($0.window?.isVisible ?? false) }) {
            newNote(nil)
        }
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        store.saveNow()
    }

    // MARK: - Actions

    @objc func newNote(_ sender: Any?) {
        let note = store.addNote()
        openWindow(for: note)
    }

    @objc func closeAllNotes(_ sender: Any?) {
        for (id, wc) in windowControllers {
            store.deleteNote(id)
            wc.close()
        }
        windowControllers.removeAll()
    }

    @objc func saveAll(_ sender: Any?) {
        store.saveNow()
    }

    // MARK: - Window Management

    func openWindow(for note: StickyNote) {
        let wc = StickyNoteWindowController(note: note, store: store)
        windowControllers[note.id] = wc
        wc.show()

        // Auto-remove closed windows from the map
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: wc.window,
            queue: .main
        ) { [weak self] _ in
            self?.windowControllers.removeValue(forKey: note.id)
        }
    }

    // MARK: - Menu

    private func buildMainMenu() {
        let mainMenu = NSMenu()
        let appName = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleName"
        ) as? String ?? "便条贴"

        // ---- App Menu ----
        let appMenu = NSMenu()
        appMenu.addItem(NSMenuItem(
            title: "关于 \(appName)",
            action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
            keyEquivalent: ""
        ))
        appMenu.addItem(.separator())
        appMenu.addItem(NSMenuItem(
            title: "退出 \(appName)",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
        mainMenu.addItem(submenu(appMenu, title: appName))

        // ---- File Menu ----
        let fileMenu = NSMenu(title: "文件")
        fileMenu.addItem(NSMenuItem(
            title: "新建便条",
            action: #selector(newNote(_:)),
            keyEquivalent: "n"
        ))
        fileMenu.addItem(NSMenuItem(
            title: "关闭所有便条",
            action: #selector(closeAllNotes(_:)),
            keyEquivalent: "K"
        ))
        fileMenu.addItem(.separator())
        fileMenu.addItem(NSMenuItem(
            title: "保存所有",
            action: #selector(saveAll(_:)),
            keyEquivalent: "s"
        ))
        mainMenu.addItem(submenu(fileMenu, title: "文件"))

        // ---- Window Menu ----
        let winMenu = NSMenu(title: "窗口")
        winMenu.addItem(NSMenuItem(
            title: "新建便条",
            action: #selector(newNote(_:)),
            keyEquivalent: "N"
        ))
        mainMenu.addItem(submenu(winMenu, title: "窗口"))

        NSApplication.shared.mainMenu = mainMenu
    }

    private func submenu(_ menu: NSMenu, title: String) -> NSMenuItem {
        let item = NSMenuItem()
        item.title = title
        item.submenu = menu
        return item
    }
}
