import SwiftUI
import CoreData

// ==============================================================================
// 🧠 ARCHITECTURAL LAYER: [VIEW MODEL / CLOUD SYNCED NOTE EDITOR]
// 📄 FILE: SyncedNoteEditorViewModel.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE REAL-TIME DRAFTING ASSISTANT ✍️☁️
// ------------------------------------------------------------------------------
// When you open the note editor in the Cloud Synced tab:
//   1. 📝 It binds to the title and content text fields in real-time.
//   2. 💾 When you tap "Save", it immediately writes to Core Data (in 0.001 seconds!).
//   3. 🚀 If you are Online: It pushes the new version to the Cloud Server.
//   4. 🔴 If you are Offline: It stamps "Pending Upload/Update" and safely queues it!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. '@Published'       -> The megaphone shouting text changes back to SwiftUI views.
// 2. 'isSaving'         -> A spinner state indicating save is processing.
// ==============================================================================

@MainActor
public class SyncedNoteEditorViewModel: ObservableObject {
    
    // --------------------------------------------------------------------------
    // 📝 1. TEXT BINDINGS & STATE
    // --------------------------------------------------------------------------
    @Published public var title: String = ""
    @Published public var content: String = ""
    @Published public var isSaving: Bool = false
    
    public let note: NoteEntity?
    private let repository: NoteRepositoryProtocol

    // --------------------------------------------------------------------------
    // 🏷️ 2. NAVIGATION TITLE HELPER
    // --------------------------------------------------------------------------
    public var navigationTitle: String {
        if let _ = note {
            return title.isEmpty ? "Edit Note" : title
        } else {
            return title.isEmpty ? "New Synced Note" : title
        }
    }

    // --------------------------------------------------------------------------
    // 🎬 3. INITIALIZER
    // --------------------------------------------------------------------------
    public init(note: NoteEntity? = nil, repository: NoteRepositoryProtocol = NoteRepository.shared) {
        self.note = note
        self.repository = repository
        
        if let existingNote = note {
            self.title = existingNote.title ?? ""
            self.content = existingNote.content ?? ""
        }
    }

    // --------------------------------------------------------------------------
    // 💾 4. SAVE RECIPE (Offline-First Save & Sync)
    // --------------------------------------------------------------------------
    public func saveNote() async {
        isSaving = true
        defer { isSaving = false }
        
        do {
            _ = try await repository.saveNote(
                id: note?.id,
                title: title,
                content: content
            )
            print("💾 [SyncedNoteEditorVM] Saved note successfully.")
        } catch {
            print("❌ [SyncedNoteEditorVM] Failed to save note: \(error.localizedDescription)")
        }
    }
}
