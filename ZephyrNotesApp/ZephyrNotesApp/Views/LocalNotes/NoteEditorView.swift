import SwiftUI

// ==============================================================================
// 👁️ ARCHITECTURAL LAYER: [VIEW / LOCAL NOTE EDITOR]
// 📄 FILE: NoteEditorView.swift (ZephyrNotesApp - Local Tab)
// ==============================================================================
//
// 🧸 STORY TIME: THE DRAWING & WRITING PAD 📝
// ------------------------------------------------------------------------------
// This screen allows typing title and content for a local standalone note.
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. '@Environment(\.dismiss)' -> Dismisses the active modal or pushed screen.
// ==============================================================================

public struct NoteEditorView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: NoteEditorViewModel
    
    public var onSave: (() -> Void)?

    public init(note: NoteEntity?, onSave: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: NoteEditorViewModel(note: note))
        self.onSave = onSave
    }

    public var body: some View {
        Form {
            Section(header: Text("Note Title")) {
                TextField("Enter title here...", text: $viewModel.title)
            }

            Section(header: Text("Note Content")) {
                TextEditor(text: $viewModel.content)
                    .frame(minHeight: 200)
            }
        }
        .navigationTitle(viewModel.navigationBarTitle)
        .toolbar {
            Button("Save") {
                viewModel.saveNote()
                onSave?()
                dismiss()
            }
        }
    }
}
