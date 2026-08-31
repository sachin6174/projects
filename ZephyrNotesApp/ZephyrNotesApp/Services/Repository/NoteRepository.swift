import Foundation
import CoreData

// ==============================================================================
// 🏛️ ARCHITECTURAL LAYER: [REPOSITORY IMPLEMENTATION]
// 📄 FILE: NoteRepository.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE MASTER COORDINATOR AT WORK 🧑‍💼🏦
// ------------------------------------------------------------------------------
// When a user writes a new note and taps "Save":
//   1. 💾 Core Data saves it in less than 1 millisecond so the screen NEVER freezes.
//   2. 📡 The repository checks: "Are we Online or Offline?"
//   3. 🟢 If ONLINE: It immediately uploads to the cloud server and marks the note as Synced!
//   4. 🔴 If OFFLINE: It stamps the note as "Pending Upload" and tells SyncEngine to
//      hold it in the outbox until Wi-Fi reconnects!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'Offline-First'    -> The golden mobile standard: Write locally first, sync remotely second!
// 2. 'Optimistic UI'    -> Show the user their note saved immediately without waiting for slow Wi-Fi.
// ==============================================================================

@MainActor
public class NoteRepository: NoteRepositoryProtocol {
    
    // --------------------------------------------------------------------------
    // 🔑 1. SHARED SINGLETON INSTANCE
    // --------------------------------------------------------------------------
    public static let shared = NoteRepository()

    // --------------------------------------------------------------------------
    // 🛠️ 2. DEPENDENCIES
    // --------------------------------------------------------------------------
    private let storageService: CoreDataStorageService
    private let syncEngine: SyncEngine
    private let networkMonitor: NetworkMonitor

    // --------------------------------------------------------------------------
    // 🎬 3. INITIALIZER
    // --------------------------------------------------------------------------
    public init(
        storageService: CoreDataStorageService = .shared,
        syncEngine: SyncEngine = .shared,
        networkMonitor: NetworkMonitor = .shared
    ) {
        self.storageService = storageService
        self.syncEngine = syncEngine
        self.networkMonitor = networkMonitor
    }

    // --------------------------------------------------------------------------
    // 📥 4. GET ALL ACTIVE NOTES
    // --------------------------------------------------------------------------
    public func getNotes() -> [NoteEntity] {
        return storageService.fetchNotes(includeDeleted: false)
    }

    // --------------------------------------------------------------------------
    // 💾 5. SAVE NOTE (Create or Update with Offline-First Queuing)
    // --------------------------------------------------------------------------
    public func saveNote(id: UUID?, title: String, content: String) async throws -> NoteEntity {
        let context = storageService.context
        let isOnline = networkMonitor.isConnected
        
        let noteEntity: NoteEntity
        let isNewNote: Bool
        
        if let existingID = id {
            let request = NoteEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", existingID as CVarArg)
            if let existing = (try? context.fetch(request) as? [NoteEntity])?.first {
                noteEntity = existing
                isNewNote = false
            } else {
                noteEntity = NoteEntity(context: context)
                noteEntity.id = existingID
                noteEntity.timestamp = Date()
                isNewNote = true
            }
        } else {
            noteEntity = NoteEntity(context: context)
            noteEntity.id = UUID()
            noteEntity.timestamp = Date()
            isNewNote = true
        }

        noteEntity.title = title
        noteEntity.content = content
        noteEntity.updatedAt = Date()
        noteEntity.isDeletedLocally = false
        noteEntity.currentSyncStatus = isNewNote ? .pendingCreate : .pendingUpdate

        storageService.saveContext()
        syncEngine.updatePendingOutboxCount()

        if isOnline {
            Task {
                await syncEngine.performSync()
            }
        }

        return noteEntity
    }

    // --------------------------------------------------------------------------
    // 🗑️ 6. DELETE NOTE
    // --------------------------------------------------------------------------
    public func deleteNote(_ note: NoteEntity) async throws {
        storageService.markForDeletion(note: note)
        syncEngine.updatePendingOutboxCount()
        
        if networkMonitor.isConnected {
            Task {
                await syncEngine.performSync()
            }
        }
    }

    // --------------------------------------------------------------------------
    // 🔄 7. MANUAL SYNC TRIGGER
    // --------------------------------------------------------------------------
    public func sync() async {
        await syncEngine.performSync()
    }
}
