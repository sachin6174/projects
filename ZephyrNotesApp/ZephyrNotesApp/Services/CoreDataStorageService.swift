import CoreData
import Foundation

// ==============================================================================
// 🛠️ ARCHITECTURAL LAYER: [SERVICE / STORAGE - ENHANCED FOR OFFLINE SYNC]
// 📄 FILE: CoreDataStorageService.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE HIGH-TECH DUAL-DESK FILING ARCHIVE 🗄️⚡
// ------------------------------------------------------------------------------
// Imagine our faithful Filing Cabinet Butler just got a massive super-upgrade!
//
// In Zephyr, our butler has TWO magical workspaces:
//   1. 🪑 The Front Desk (viewContext on Main Thread):
//      Fast and responsive! This is where SwiftUI draws screens at 120 frames per second.
//   2. 🏢 The Secret Back-Office (Background Contexts):
//      Where large batches of cloud notes are processed, merged, and saved silently
//      without causing a single stutter or dropped frame on your iPhone screen!
//   3. ⚡ Automatic Merging & Smart Overwrite (NSMergeByPropertyObjectTrumpMergePolicy):
//      When the back-office finishes saving, changes automatically teleport to the
//      front desk so your screen updates instantly!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'NSPersistentContainer'          -> The master filing cabinet holding the SQLite database.
// 2. 'NSManagedObjectContext'         -> A study desk / scratchpad in RAM for creating & editing notes.
// 3. 'viewContext'                    -> The Main Thread study desk (strictly for UI display).
// 4. 'newBackgroundContext()'         -> Spawns a brand new private desk on a background worker thread.
// 5. 'automaticallyMergesChanges'     -> Magic Teleportation: Auto-refreshes front desk when back desk saves!
// 6. 'NSMergeByPropertyObjectTrump'   -> Smart conflict resolution: Overwrites conflicting attributes cleanly.
// 7. 'Batch Upsert'                   -> Update if exists, Insert if brand new (in one smooth operation).
// 8. 'Tombstone'                      -> A marker left behind for a deleted note so the cloud knows to delete it.
// ==============================================================================

public class CoreDataStorageService {
    
    // --------------------------------------------------------------------------
    // 🔑 1. THE ONE GOLDEN KEY (Singleton Pattern)
    // --------------------------------------------------------------------------
    public static let shared = CoreDataStorageService()

    // --------------------------------------------------------------------------
    // 🗄️ 2. THE MASTER FILING CABINET (NSPersistentContainer)
    // --------------------------------------------------------------------------
    public let container: NSPersistentContainer

    // --------------------------------------------------------------------------
    // 🪑 3. FRONT STUDY DESK (Main Thread UI Context)
    // --------------------------------------------------------------------------
    public var context: NSManagedObjectContext {
        return container.viewContext
    }

    // --------------------------------------------------------------------------
    // 🚪 4. OPENING THE CABINET & CONFIGURING OPTIMIZATIONS
    // --------------------------------------------------------------------------
    public init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "NoteModel")
        
        // Step A: Configure lightweight automatic migration options
        if let description = container.persistentStoreDescriptions.first {
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
            
            if inMemory {
                description.url = URL(fileURLWithPath: "/dev/null")
            }
        }
        
        // Step B: Load persistent stores from disk
        container.loadPersistentStores { description, error in
            if let error = error {
                print("❌ [CoreData] Failed to load store: \(error.localizedDescription)")
            } else {
                print("✅ [CoreData] Store loaded successfully with lightweight migration enabled.")
            }
        }
        
        // Step C: High-Performance Optimizations on the Main UI Context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // --------------------------------------------------------------------------
    // 🏢 5. SPAWNING A BACKGROUND CONTEXT (Off-Main-Thread Worker)
    // --------------------------------------------------------------------------
    public func newBackgroundContext() -> NSManagedObjectContext {
        let bgContext = container.newBackgroundContext()
        bgContext.automaticallyMergesChangesFromParent = true
        bgContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return bgContext
    }

    // --------------------------------------------------------------------------
    // 🔒 6. SAVING CHANGES ON A GIVEN CONTEXT (or Main Context by Default)
    // --------------------------------------------------------------------------
    public func saveContext(_ targetContext: NSManagedObjectContext? = nil) {
        let ctx = targetContext ?? context
        if ctx.hasChanges {
            do {
                try ctx.save()
                print("💾 [CoreData] Saved context successfully.")
            } catch {
                print("❌ [CoreData] Failed to save context: \(error.localizedDescription)")
            }
        }
    }

    // --------------------------------------------------------------------------
    // 📥 7. FETCHING NOTES (Excluding Soft-Deleted Notes by Default)
    // --------------------------------------------------------------------------
    public func fetchNotes(includeDeleted: Bool = false) -> [NoteEntity] {
        let request = NoteEntity.fetchRequest()
        
        if !includeDeleted {
            request.predicate = NSPredicate(format: "isDeletedLocally == NO")
        }
        
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \NoteEntity.timestamp, ascending: false)
        ]
        
        do {
            let results = try context.fetch(request) as? [NoteEntity]
            return results ?? []
        } catch {
            print("❌ [CoreData] Fetch error: \(error.localizedDescription)")
            return []
        }
    }

    // --------------------------------------------------------------------------
    // 📤 8. FETCHING OUTBOX ITEMS (Pending Synchronization)
    // --------------------------------------------------------------------------
    public func fetchPendingSyncNotes(in targetContext: NSManagedObjectContext? = nil) -> [NoteEntity] {
        let ctx = targetContext ?? context
        let request = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "syncStatus != %@", SyncStatus.synced.rawValue)
        
        do {
            let results = try ctx.fetch(request) as? [NoteEntity]
            return results ?? []
        } catch {
            print("❌ [CoreData] Outbox fetch error: \(error.localizedDescription)")
            return []
        }
    }

    // --------------------------------------------------------------------------
    // ⚡ 9. HIGH-PERFORMANCE BATCH UPSERT FROM NETWORK (Background Task)
    // --------------------------------------------------------------------------
    public func batchUpsert(dtos: [NoteDTO], completion: (@Sendable (Result<Void, Error>) -> Void)? = nil) {
        container.performBackgroundTask { bgContext in
            bgContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            do {
                let incomingIDs = dtos.map { $0.id }
                let request = NoteEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id IN %@", incomingIDs)
                let existingNotes = (try bgContext.fetch(request) as? [NoteEntity]) ?? []
                
                var existingDict: [UUID: NoteEntity] = [:]
                for entity in existingNotes {
                    if let id = entity.id {
                        existingDict[id] = entity
                    }
                }
                
                for dto in dtos {
                    if let existingEntity = existingDict[dto.id] {
                        if existingEntity.currentSyncStatus == .synced {
                            existingEntity.update(from: dto)
                        }
                    } else {
                        let newEntity = NoteEntity(context: bgContext)
                        newEntity.update(from: dto)
                    }
                }
                
                if bgContext.hasChanges {
                    try bgContext.save()
                    print("✅ [CoreData] Background batch upsert saved \(dtos.count) notes.")
                }
                
                completion?(.success(()))
            } catch {
                print("❌ [CoreData] Batch upsert failed: \(error.localizedDescription)")
                completion?(.failure(error))
            }
        }
    }

    // --------------------------------------------------------------------------
    // 🗑️ 10. SOFT-DELETE (For Offline-First Deletions)
    // --------------------------------------------------------------------------
    public func markForDeletion(note: NoteEntity) {
        if note.currentSyncStatus == .pendingCreate {
            context.delete(note)
        } else {
            note.isDeletedLocally = true
            note.currentSyncStatus = .pendingDelete
            note.updatedAt = Date()
        }
        saveContext()
    }

    // --------------------------------------------------------------------------
    // 🧹 11. PERMANENT REMOVAL (After Cloud Confirms Deletion)
    // --------------------------------------------------------------------------
    public func permanentlyDeleteNote(id: UUID, in targetContext: NSManagedObjectContext? = nil) {
        let ctx = targetContext ?? context
        let request = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let entity = (try ctx.fetch(request) as? [NoteEntity])?.first {
                ctx.delete(entity)
                try ctx.save()
                print("🗑️ [CoreData] Permanently deleted note \(id).")
            }
        } catch {
            print("❌ [CoreData] Failed to permanently delete note: \(error.localizedDescription)")
        }
    }
}
