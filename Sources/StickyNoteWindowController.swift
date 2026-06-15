import SwiftUI
import AppKit

// MARK: - Window Controller per Note
final class StickyNoteWindowController: NSWindowController, NSWindowDelegate {

    private let noteID: UUID
    private let store: NoteStore

    init(note: StickyNote, store: NoteStore) {
        self.noteID = note.id
        self.store = store

        let window = StickyNoteWindow(note: note)
        super.init(window: window)

        window.delegate = self

        // Embed SwiftUI view
        let noteID = note.id
        let hostingView = NSHostingView(
            rootView: StickyNoteView(
                store: store,
                noteID: noteID,
                onClose: { [weak self] in self?.closeNote() },
                onContentChanged: { text in store.updateContent(noteID, content: text) },
                onColorChange: { hex in store.updateColor(noteID, hex: hex) },
                onOpacityChange: { val in
                    store.updateOpacity(noteID, opacity: val)
                    window.alphaValue = val
                },
                onFontSizeChange: { size in store.updateFontSize(noteID, size: size) },
                onPinToggle: { [weak self] pinned in
                    store.updatePin(noteID, pinned: pinned)
                    (self?.window as? StickyNoteWindow)?.setPinned(pinned)
                }
            )
        )
        hostingView.autoresizingMask = [.width, .height]
        window.contentView = hostingView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    func show() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate()
    }

    private func closeNote() {
        store.deleteNote(noteID)
        window?.close()
    }

    // MARK: - NSWindowDelegate

    func windowDidResize(_ notification: Notification) {
        guard let frame = window?.frame else { return }
        let clamped = constrainToScreen(frame)
        store.updateSize(noteID, size: clamped.size)
    }

    func windowDidMove(_ notification: Notification) {
        guard let frame = window?.frame else { return }
        let clamped = constrainToScreen(frame)
        store.updatePosition(noteID, position: CGPoint(x: clamped.origin.x,
                                                        y: clamped.origin.y))
    }

    func windowWillClose(_ notification: Notification) {
        store.saveNow()
    }

    func windowDidBecomeKey(_ notification: Notification) {
        // Ensure the app is active so TextEditor receives focus properly
        if !NSApp.isActive {
            NSApp.activate()
        }
    }

    // Keep window within visible screen bounds
    private func constrainToScreen(_ frame: NSRect) -> NSRect {
        guard let screen = window?.screen ?? NSScreen.main else { return frame }
        let visible = screen.visibleFrame
        var newFrame = frame

        // Minimum visibility: at least 60pt of the window must be visible
        let minVisible: CGFloat = 60
        let pad: CGFloat = 20

        if newFrame.maxX < visible.minX + minVisible {
            newFrame.origin.x = visible.minX - newFrame.width + minVisible
        }
        if newFrame.minX > visible.maxX - minVisible {
            newFrame.origin.x = visible.maxX - minVisible
        }
        if newFrame.maxY < visible.minY + minVisible {
            newFrame.origin.y = visible.minY - newFrame.height + minVisible
        }
        if newFrame.minY > visible.maxY - minVisible {
            newFrame.origin.y = visible.maxY - minVisible
        }

        // Clamp to reasonable bounds
        newFrame.origin.x = max(visible.minX - newFrame.width + pad,
                                min(visible.maxX - pad, newFrame.origin.x))
        newFrame.origin.y = max(visible.minY - newFrame.height + pad,
                                min(visible.maxY - pad, newFrame.origin.y))

        return newFrame
    }
}
