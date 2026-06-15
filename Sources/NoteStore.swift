import Foundation
import AppKit
import Combine

/// Singleton managing all sticky notes: in-memory state + disk persistence.
final class NoteStore: ObservableObject {
    static let shared = NoteStore()

    @Published var notes: [StickyNote] = []

    private let fileURL: URL
    private var saveWorkItem: DispatchWorkItem?

    private init() {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        let dir = appSupport.appendingPathComponent("Sticky")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("notes.json")
        load()
    }

    // MARK: - CRUD

    @discardableResult
    func addNote(at position: CGPoint? = nil) -> StickyNote {
        let pos = position ?? randomPosition()
        let note = StickyNote(position: pos)
        notes.append(note)
        scheduleSave()
        return note
    }

    func updateContent(_ id: UUID, content: String) {
        guard let i = notes.firstIndex(where: { $0.id == id }) else { return }
        notes[i].content = content
        notes[i].updatedAt = Date()
        scheduleSave()
    }

    func updatePosition(_ id: UUID, position: CGPoint) {
        guard let i = notes.firstIndex(where: { $0.id == id }) else { return }
        notes[i].position = position
        notes[i].updatedAt = Date()
        scheduleSave()
    }

    func updateSize(_ id: UUID, size: CGSize) {
        guard let i = notes.firstIndex(where: { $0.id == id }) else { return }
        notes[i].size = size
        notes[i].updatedAt = Date()
        scheduleSave()
    }

    func updateColor(_ id: UUID, hex: String) {
        guard let i = notes.firstIndex(where: { $0.id == id }) else { return }
        notes[i].colorHex = hex
        notes[i].updatedAt = Date()
        scheduleSave()
    }

    func updateOpacity(_ id: UUID, opacity: Double) {
        guard let i = notes.firstIndex(where: { $0.id == id }) else { return }
        notes[i].opacity = max(0.2, min(1.0, opacity))
        notes[i].updatedAt = Date()
        scheduleSave()
    }

    func updatePin(_ id: UUID, pinned: Bool) {
        guard let i = notes.firstIndex(where: { $0.id == id }) else { return }
        notes[i].isPinned = pinned
        notes[i].updatedAt = Date()
        scheduleSave()
    }

    func updateFontSize(_ id: UUID, size: CGFloat) {
        guard let i = notes.firstIndex(where: { $0.id == id }) else { return }
        notes[i].fontSize = max(10, min(48, size))
        notes[i].updatedAt = Date()
        scheduleSave()
    }

    func deleteNote(_ id: UUID) {
        notes.removeAll { $0.id == id }
        scheduleSave()
    }

    func saveNow() {
        saveWorkItem?.cancel()
        encodeAndWrite()
    }

    // MARK: - Persistence

    private func scheduleSave() {
        saveWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.encodeAndWrite()
        }
        saveWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: work)
    }

    private func encodeAndWrite() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(notes)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("[NoteStore] Save failed: \(error)")
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            notes = try decoder.decode([StickyNote].self, from: data)
        } catch {
            print("[NoteStore] Load failed: \(error)")
            notes = []
        }
    }

    private func randomPosition() -> CGPoint {
        guard let screen = NSScreen.main else {
            return CGPoint(x: 300, y: 300)
        }
        let visible = screen.visibleFrame
        let x = Double.random(in: visible.minX + 50 ... visible.maxX - 300)
        let y = Double.random(in: visible.minY + 50 ... visible.maxY - 300)
        return CGPoint(x: x, y: y)
    }
}
