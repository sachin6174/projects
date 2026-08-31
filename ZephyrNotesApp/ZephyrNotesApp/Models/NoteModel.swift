import Foundation
import CoreData
import SwiftUI

// ==============================================================================
// 📦 ARCHITECTURAL LAYER: [MODEL]
// 📄 FILE: NoteModel.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: WHAT IS A MODEL? (THE ENHANCED NOTE CARD BLUEPRINT)
// ------------------------------------------------------------------------------
// Imagine you are making a super cool recipe book or collecting superhero cards.
// Before you can make any card, you need a blueprint!
//
// In Zephyr, every single note card has:
//   1. id               -> A unique serial number sticker (UUID).
//   2. title            -> The headline or topic of your note.
//   3. content          -> The full story or text you typed.
//   4. timestamp        -> The local clock time when created or edited.
//   5. syncStatus       -> A status stamp! ("synced", "pendingCreate", "pendingUpdate", "pendingDelete").
//   6. updatedAt        -> The latest update time for smart conflict resolution.
//   7. isDeletedLocally -> A secret trash bin tag for offline soft-deletes.
//   8. serverVersion    -> A version badge to ensure cloud synchronization consistency.
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'Foundation'       -> Apple's basic toolkit for numbers, dates, & text.
// 2. 'CoreData'         -> Apple's super-secure magic vault for saving data to the hard drive.
// 3. 'SwiftUI'          -> Apple's modern UI toolkit for colors, badges, and icons.
// 4. '@objc(NoteEntity)'-> A bridge tag telling older Apple systems the name of our entity.
// 5. 'public'           -> "Everyone in the project is allowed to see and use this!"
// 6. 'class'            -> A blueprint for creating reference objects living in memory.
// 7. 'NSManagedObject'  -> A special Core Data object that lives inside the database vault.
// 8. 'Identifiable'     -> A badge that says: "Every note has a unique ID, so SwiftUI can tell them apart!"
// 9. '@NSManaged'       -> A magic tag: "Hey Core Data! Save and load this box automatically!"
// 10.'enum'             -> A list of specific choices (like Traffic Light: Red, Yellow, Green).
// 11.'SyncStatus'       -> Our sync state enum: synced, pendingCreate, pendingUpdate, pendingDelete.
// ==============================================================================

// ------------------------------------------------------------------------------
// 🚦 SYNC STATUS ENUM: THE 4 STAGES OF A NOTE'S CLOUD JOURNEY
// ------------------------------------------------------------------------------
public enum SyncStatus: String, Codable, CaseIterable {
    case synced = "synced"                     // ☁️ Green: Safely saved both on device and cloud
    case pendingCreate = "pendingCreate"       // 📤 Blue: Created while offline, waiting to upload
    case pendingUpdate = "pendingUpdate"       // ✏️ Orange: Edited while offline, waiting to sync changes
    case pendingDelete = "pendingDelete"       // 🗑️ Red: Deleted while offline, waiting to delete on cloud
}

@objc(NoteEntity)
public class NoteEntity: NSManagedObject, Identifiable {
    
    // --------------------------------------------------------------------------
    // 🏷️ THE LABELED BOXES ON OUR NOTE CARD (Core Data Attributes)
    // --------------------------------------------------------------------------
    
    // Box 1: A unique sticker ID so SwiftUI & the Server never confuse two notes
    @NSManaged public var id: UUID?
    
    // Box 2: The short headline or title of the note
    @NSManaged public var title: String?
    
    // Box 3: The long paragraph, secret story, or list of chores
    @NSManaged public var content: String?
    
    // Box 4: The exact calendar date and clock time created/edited
    @NSManaged public var timestamp: Date?
    
    // Box 5: Raw sync status string saved in Core Data ("synced", "pendingCreate", etc.)
    @NSManaged public var syncStatus: String?
    
    // Box 6: The exact last updated timestamp for conflict resolution
    @NSManaged public var updatedAt: Date?
    
    // Box 7: Soft-delete flag (marks item as deleted locally so it syncs deletion to server)
    @NSManaged public var isDeletedLocally: Bool
    
    // Box 8: Remote server version number (detects concurrent edit conflicts)
    @NSManaged public var serverVersion: Int32

    // --------------------------------------------------------------------------
    // 🚦 TYPED SYNC STATUS PROPERTY
    // --------------------------------------------------------------------------
    public var currentSyncStatus: SyncStatus {
        get {
            guard let rawStatus = syncStatus, let status = SyncStatus(rawValue: rawStatus) else {
                return .synced
            }
            return status
        }
        set {
            syncStatus = newValue.rawValue
        }
    }

    // --------------------------------------------------------------------------
    // 🎨 HELPER 1: FRIENDLY TITLE (displayTitle)
    // --------------------------------------------------------------------------
    public var displayTitle: String {
        if let title = title {
            let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            if !cleanTitle.isEmpty {
                return cleanTitle
            }
        }
        return "Untitled Note"
    }

    // --------------------------------------------------------------------------
    // 📝 HELPER 2: CONTENT PREVIEW (displaySnippet)
    // --------------------------------------------------------------------------
    public var displaySnippet: String {
        if let content = content {
            let clean = content.trimmingCharacters(in: .whitespacesAndNewlines)
            if !clean.isEmpty {
                let firstLine = clean.components(separatedBy: .newlines).first ?? clean
                return firstLine
            }
        }
        return "No additional text"
    }

    // --------------------------------------------------------------------------
    // ⏰ HELPER 3: PRETTY DATE STAMP (displayDate)
    // --------------------------------------------------------------------------
    public var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let dateToFormat = updatedAt ?? timestamp ?? Date()
        return formatter.string(from: dateToFormat)
    }

    // --------------------------------------------------------------------------
    // 🏷️ HELPER 4: SYNC STATUS BADGE HELPERS (Colors, Icons, and Text)
    // --------------------------------------------------------------------------
    public var statusBadgeColor: Color {
        switch currentSyncStatus {
        case .synced:
            return .green
        case .pendingCreate:
            return .blue
        case .pendingUpdate:
            return .orange
        case .pendingDelete:
            return .red
        }
    }
    
    public var statusIconName: String {
        switch currentSyncStatus {
        case .synced:
            return "checkmark.icloud.fill"
        case .pendingCreate:
            return "arrow.up.icloud.fill"
        case .pendingUpdate:
            return "arrow.triangle.2.circlepath.icloud.fill"
        case .pendingDelete:
            return "xmark.icloud.fill"
        }
    }
    
    public var statusDisplayText: String {
        switch currentSyncStatus {
        case .synced:
            return "Synced"
        case .pendingCreate:
            return "Pending Upload"
        case .pendingUpdate:
            return "Pending Update"
        case .pendingDelete:
            return "Pending Deletion"
        }
    }
    
    public var isPendingSync: Bool {
        return currentSyncStatus != .synced
    }

    // --------------------------------------------------------------------------
    // 🔄 HELPER 5: CONVERSION TO DTO (Data Transfer Object for Network)
    // --------------------------------------------------------------------------
    public func toDTO() -> NoteDTO {
        return NoteDTO(
            id: self.id ?? UUID(),
            title: self.title ?? "",
            content: self.content ?? "",
            createdAt: self.timestamp ?? Date(),
            updatedAt: self.updatedAt ?? self.timestamp ?? Date(),
            version: Int(self.serverVersion > 0 ? self.serverVersion : 1)
        )
    }

    // --------------------------------------------------------------------------
    // 📥 HELPER 6: POPULATE FROM DTO (Updating Core Data from Network)
    // --------------------------------------------------------------------------
    public func update(from dto: NoteDTO) {
        self.id = dto.id
        self.title = dto.title
        self.content = dto.content
        self.timestamp = dto.createdAt
        self.updatedAt = dto.updatedAt
        self.serverVersion = Int32(dto.version)
        self.currentSyncStatus = .synced
        self.isDeletedLocally = false
    }
}
