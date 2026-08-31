import SwiftUI
import CoreData

// ==============================================================================
// 🧠 ARCHITECTURAL LAYER: [VIEW MODEL / LOCAL NOTE EDITOR]
// 📄 FILE: NoteEditorViewModel.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE NOTE-WRITING ASSISTANT ✍️
// ------------------------------------------------------------------------------
// This View Model is our local note editor assistant that binds to user typing
// and saves new or edited notes straight to Core Data.
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'ObservableObject' -> Broadcasts changes to SwiftUI.
// 2. '@Published'       -> Megaphone notifying SwiftUI views.
// ==============================================================================

public class NoteEditorViewModel: ObservableObject {
    
    private var note: NoteEntity?
    private let storageService = CoreDataStorageService.shared

    @Published public var title: String = ""
    @Published public var content: String = ""

    public var navigationBarTitle: String {
        if title.isEmpty {
            return "New Note"
        } else {
            return title
        }
    }

    public init(note: NoteEntity? = nil) {
        self.note = note
        
        if let note = note {
            self.title = note.title ?? ""
            self.content = note.content ?? ""
        }
    }

    public func saveNote() {
        let context = storageService.context
        let noteToSave: NoteEntity
        
        if let existingNote = note {
            noteToSave = existingNote
        } else {
            noteToSave = NoteEntity(context: context)
            noteToSave.id = UUID()
            noteToSave.timestamp = Date()
        }

        noteToSave.title = title
        noteToSave.content = content
        noteToSave.updatedAt = Date()
        noteToSave.currentSyncStatus = .synced
        noteToSave.isDeletedLocally = false

        storageService.saveContext()
    }
}
