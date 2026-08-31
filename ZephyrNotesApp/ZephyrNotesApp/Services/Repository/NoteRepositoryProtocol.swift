import Foundation
import CoreData

// ==============================================================================
// 🏛️ ARCHITECTURAL LAYER: [REPOSITORY / PROTOCOL ABSTRACTION]
// 📄 FILE: NoteRepositoryProtocol.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE SINGLE WINDOW AT THE BANK 🏦🪟
// ------------------------------------------------------------------------------
// Imagine you go to a big bank with underground vaults, high-speed computers,
// security guards, and satellite dishes.
//
// You don't have to wander into the basement vault yourself!
// You simply walk up to ONE friendly teller window:
//   - "Please give me my notes!"
//   - "Please save this new note!"
//   - "Please delete this old note!"
//
// In Clean Architecture, the REPOSITORY is that single teller window.
// It hides all the complex database queries and cloud network requests behind
// a clean, elegant API so ViewModels stay super simple and testable!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'Repository Pattern' -> A design pattern that provides a single source of truth.
// 2. 'CRUD'               -> Create, Read, Update, Delete.
// ==============================================================================

@MainActor
public protocol NoteRepositoryProtocol {
    
    // 1. Get all active notes from local storage
    func getNotes() -> [NoteEntity]
    
    // 2. Save (create or update) a note with immediate local save & cloud sync
    func saveNote(id: UUID?, title: String, content: String) async throws -> NoteEntity
    
    // 3. Delete a note (handles offline soft-delete and cloud deletion)
    func deleteNote(_ note: NoteEntity) async throws
    
    // 4. Trigger manual full synchronization with the cloud
    func sync() async
}
