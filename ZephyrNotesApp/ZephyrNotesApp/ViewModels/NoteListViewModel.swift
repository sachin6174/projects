import SwiftUI
import CoreData

// ==============================================================================
// 🧠 ARCHITECTURAL LAYER: [VIEW MODEL / LOCAL STANDALONE NOTES]
// 📄 FILE: NoteListViewModel.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE HELPFUL PERSONAL ASSISTANT 🧑‍💼
// ------------------------------------------------------------------------------
// This View Model is our classic Personal Assistant for standalone local notes.
// It talks directly to Core Data to fetch and delete notes on disk.
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'ObservableObject' -> A class that notifies SwiftUI when its @Published variables change.
// 2. '@Published'       -> Megaphone notifying SwiftUI views to redraw.
// ==============================================================================

public class NoteListViewModel: ObservableObject {
    
    @Published public var notes: [NoteEntity] = []
    private let storageService = CoreDataStorageService.shared

    public init() {
        fetchNotes()
    }

    public func fetchNotes() {
        self.notes = storageService.fetchNotes(includeDeleted: false)
    }

    public func deleteNote(at offsets: IndexSet) {
        for index in offsets {
            let noteToDelete = notes[index]
            storageService.context.delete(noteToDelete)
        }
        storageService.saveContext()
        fetchNotes()
    }
}
