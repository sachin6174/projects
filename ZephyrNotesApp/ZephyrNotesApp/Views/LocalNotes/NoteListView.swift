import SwiftUI

// ==============================================================================
// 👁️ ARCHITECTURAL LAYER: [VIEW / LOCAL STANDALONE NOTES LIST]
// 📄 FILE: NoteListView.swift (ZephyrNotesApp - Local Tab)
// ==============================================================================
//
// 🧸 STORY TIME: THE REFRIGERATOR MAGNETIC BOARD 📋
// ------------------------------------------------------------------------------
// This screen represents the classic standalone local note list, reading
// directly from Core Data on disk!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. '@StateObject'    -> Keeps the view model alive in memory.
// 2. 'NavigationStack' -> Container supporting push/pop view navigation.
// ==============================================================================

public struct NoteListView: View {
    
    @StateObject private var viewModel = NoteListViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.notes) { note in
                    NavigationLink(destination: NoteEditorView(note: note, onSave: {
                        viewModel.fetchNotes()
                    })) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.displayTitle)
                                .font(.headline)
                            
                            Text(note.displayDate)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete { offsets in
                    viewModel.deleteNote(at: offsets)
                }
            }
            .navigationTitle("Local Notes 📝")
            .overlay {
                if viewModel.notes.isEmpty {
                    Text("No local notes yet.\nTap '+' to create one.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                }
            }
            .toolbar {
                NavigationLink(destination: NoteEditorView(note: nil, onSave: {
                    viewModel.fetchNotes()
                })) {
                    Image(systemName: "plus")
                }
            }
            .onAppear {
                viewModel.fetchNotes()
            }
        }
    }
}
