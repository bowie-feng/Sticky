import SwiftUI

// MARK: - Main Note View
struct StickyNoteView: View {
    @ObservedObject var store: NoteStore
    let noteID: UUID

    @State private var title: String = ""
    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    // Callbacks
    var onClose: () -> Void
    var onTitleChanged: (String) -> Void
    var onContentChanged: (String) -> Void
    var onColorChange: (String) -> Void
    var onOpacityChange: (Double) -> Void
    var onFontSizeChange: (CGFloat) -> Void
    var onPinToggle: (Bool) -> Void

    /// Look up the latest note from the store so color/size/opacity changes take effect.
    private var note: StickyNote? {
        store.notes.first(where: { $0.id == noteID })
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Background
            if let note {
                Color(hex: note.colorHex)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(spacing: 0) {
                // ---- Toolbar ----
                HStack {
                    // Pin indicator
                    if let note, note.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary.opacity(0.5))
                            .padding([.top, .leading], 6)
                    }
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                    .padding([.top, .trailing], 6)
                }

                // ---- Title Field ----
                TextField("标题", text: $title)
                    .font(.system(size: (note?.fontSize ?? 14) + 2, weight: .bold))
                    .textFieldStyle(.plain)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
                    .padding(.top, 2)
                    .onChange(of: title) { _, newValue in
                        onTitleChanged(newValue)
                    }

                Divider()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)

                // ---- Text Editor ----
                if let note {
                    TextEditor(text: $text)
                        .font(.system(size: note.fontSize))
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .foregroundColor(.primary)   // readable in both light & dark mode
                        .focused($isFocused)
                        .padding(.horizontal, 10)
                        .onChange(of: text) { _, newValue in
                            onContentChanged(newValue)
                        }
                }

                // ---- Bottom resize handle ----
                HStack {
                    Spacer()
                    Image(systemName: "arrow.up.backward.and.arrow.down.forward")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.5))
                        .padding([.bottom, .trailing], 4)
                }
            }
        }
        .onAppear {
            title = note?.title ?? ""
            text = note?.content ?? ""
        }
        .onChange(of: note?.title) { _, newValue in
            if let newValue, title != newValue {
                title = newValue
            }
        }
        .onChange(of: note?.content) { _, newValue in
            if let newValue, text != newValue {
                text = newValue
            }
        }
        .contextMenu {
            contextMenuContent
        }
    }

    // MARK: - Context Menus

    @ViewBuilder
    private var contextMenuContent: some View {
        // Pin / Unpin
        if let note {
            Button {
                onPinToggle(!note.isPinned)
            } label: {
                HStack {
                    if note.isPinned {
                        Text("取消固定")
                        Image(systemName: "pin.slash")
                    } else {
                        Text("固定到桌面")
                        Image(systemName: "pin")
                    }
                }
            }
        }
        Divider()
        Menu("更改颜色") {
            ForEach(NotePalette.colors, id: \.hex) { item in
                Button {
                    onColorChange(item.hex)
                } label: {
                    HStack {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: item.hex))
                            .frame(width: 14, height: 14)
                        Text(item.name)
                        if note?.colorHex == item.hex {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        Divider()
        Menu("透明度") {
            ForEach([1.0, 0.92, 0.80, 0.65, 0.50, 0.35], id: \.self) { val in
                Button {
                    onOpacityChange(val)
                } label: {
                    HStack {
                        Text("\(Int(val * 100))%")
                        if abs((note?.opacity ?? 0) - val) < 0.01 {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        Menu("字体大小") {
            ForEach([10, 12, 14, 16, 18, 22, 28, 36], id: \.self) { size in
                Button {
                    onFontSizeChange(CGFloat(size))
                } label: {
                    HStack {
                        Text("\(size) pt")
                        if abs((note?.fontSize ?? 0) - CGFloat(size)) < 1 {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        Divider()
        Button("删除便条") {
            onClose()
        }
    }
}
