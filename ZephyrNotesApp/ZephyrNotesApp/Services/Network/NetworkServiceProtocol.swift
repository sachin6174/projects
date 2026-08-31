import Foundation

// ==============================================================================
// 🌐 ARCHITECTURAL LAYER: [NETWORK / PROTOCOL ABSTRACTION]
// 📄 FILE: NetworkServiceProtocol.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE UNIVERSAL REMOTE CONTROL 🎮✨
// ------------------------------------------------------------------------------
// Imagine you have a magical Universal Remote Control that has buttons for:
//   - "Fetch Notes"
//   - "Create Note"
//   - "Update Note"
//   - "Delete Note"
//
// The remote doesn't care if it's talking to a Real Cloud Server in Silicon Valley,
// or a Simulated In-Memory Server right inside Xcode!
//
// In Swift architecture, a PROTOCOL is the contract blueprint for that remote.
// This allows us to swap between `MockNetworkService` (for offline testing/demos)
// and `URLSessionNetworkService` (for real production backends) with ZERO changes
// to our ViewModels or SyncEngine!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'protocol'         -> A binding contract: "Any class following me MUST have these functions!"
// 2. 'async'            -> Pausable function that runs smoothly in the background without freezing the UI.
// 3. 'throws'           -> Can throw an error if something goes wrong (handled with do-try-catch).
// 4. 'Sendable'         -> Safe to use concurrently across multiple Swift tasks and actors.
// ==============================================================================

public protocol NetworkServiceProtocol: Sendable {
    
    // 1. Fetch all notes from the remote cloud
    func fetchNotes() async throws -> [NoteDTO]
    
    // 2. Fetch a single note by its unique identifier
    func fetchNote(id: UUID) async throws -> NoteDTO
    
    // 3. Upload a newly created note to the remote cloud
    func createNote(_ note: NoteDTO) async throws -> NoteDTO
    
    // 4. Update an existing note on the remote cloud
    func updateNote(_ note: NoteDTO) async throws -> NoteDTO
    
    // 5. Delete a note from the remote cloud
    func deleteNote(id: UUID) async throws
    
    // 6. Batch synchronize an array of pending outbox notes (for fast bulk catch-up)
    func syncBatch(notes: [NoteDTO]) async throws -> [NoteDTO]
}
