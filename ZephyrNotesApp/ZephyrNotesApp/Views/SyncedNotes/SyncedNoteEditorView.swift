import SwiftUI

// ==============================================================================
// 👁️ ARCHITECTURAL LAYER: [VIEW / CLOUD SYNCED NOTE EDITOR]
// 📄 FILE: SyncedNoteEditorView.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE REAL-TIME CLOUD CANVAS 🎨☁️
// ------------------------------------------------------------------------------
// When you open this editor:
//   - You can type your ideas freely, whether connected to Wi-Fi or offline in an airplane!
//   - Tapping "Save" writes directly to your local database instantly, and if online,
//     pushes to the cloud server in the background.
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. '@Environment(\.dismiss)' -> Dismisses the active screen to slide back.
// 2. '@StateObject'            -> Manages the editor view model lifecycle.
// ==============================================================================

public struct SyncedNoteEditorView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SyncedNoteEditorViewModel
    @ObservedObject private var networkMonitor = NetworkMonitor.shared
    
    public var onSave: (() -> Void)?

    public init(note: NoteEntity? = nil, onSave: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: SyncedNoteEditorViewModel(note: note))
        self.onSave = onSave
    }

    public var body: some View {
        Form {
            Section(header: Text("Note Title")) {
                TextField("Enter title here...", text: $viewModel.title)
                    .font(.body)
            }

            Section(header: Text("Content"), footer: syncHintFooter) {
                TextEditor(text: $viewModel.content)
                    .frame(minHeight: 220)
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    Task {
                        await viewModel.saveNote()
                        onSave?()
                        dismiss()
                    }
                }
                .disabled(viewModel.isSaving)
                .fontWeight(.bold)
            }
        }
    }

    private var syncHintFooter: some View {
        HStack(spacing: 6) {
            Image(systemName: networkMonitor.isConnected ? "icloud.fill" : "wifi.slash")
                .foregroundColor(networkMonitor.isConnected ? .blue : .orange)
            
            Text(networkMonitor.isConnected
                 ? "Note will be saved locally & immediately synced to the cloud."
                 : "Offline: Note will be saved locally and queued to sync upon reconnect.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.top, 4)
    }
}
