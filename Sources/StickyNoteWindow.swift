import SwiftUI
import AppKit

// MARK: - Borderless Desktop Window Subclass
final class StickyNoteWindow: NSWindow {

    init(note: StickyNote) {
        super.init(
            contentRect: CGRect(origin: note.position, size: note.size),
            styleMask: [.borderless, .resizable],
            backing: .buffered,
            defer: false
        )

        configureAppearance()
        setInitialOpacity(note.opacity)
        setPinned(note.isPinned)
    }

    private func configureAppearance() {
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true

        // Use normal window level so the note behaves like a regular window:
        //   - Clickable and editable (unlike desktop level which eats events)
        //   - Sits behind other apps when they are active (unlike .floating)
        //   - Visible when looking at the desktop
        // This is the same approach the built-in Stickies app uses.
        level = .normal

        collectionBehavior = [.canJoinAllSpaces, .stationary]
        titlebarAppearsTransparent = true
        minSize = NSSize(width: 160, height: 120)

        // Rounded corners on the whole window
        contentView?.wantsLayer = true
        contentView?.layer?.cornerRadius = 8
        contentView?.layer?.masksToBounds = true
    }

    private func setInitialOpacity(_ opacity: Double) {
        alphaValue = opacity
    }

    /// When pinned, the note cannot be dragged around.
    func setPinned(_ pinned: Bool) {
        isMovableByWindowBackground = !pinned
    }

    // MARK: - Key handling: close on Escape
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape key
            close()
        } else {
            super.keyDown(with: event)
        }
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
