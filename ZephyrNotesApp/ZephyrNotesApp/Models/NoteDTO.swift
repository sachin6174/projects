import Foundation

// ==============================================================================
// 📦 ARCHITECTURAL LAYER: [MODEL / DTO (DATA TRANSFER OBJECT)]
// 📄 FILE: NoteDTO.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE ENVELOPE THAT TRAVELS ACROSS THE CLOUDS ✉️☁️
// ------------------------------------------------------------------------------
// Imagine you want to send a secret drawing or note to your friend who lives
// in another city across the ocean.
//
// You cannot just send your whole heavy wooden desk through the mail!
// Instead, you fold your letter nicely, slip it into a lightweight paper ENVELOPE,
// write a stamp on it, and give it to the mail carrier.
//
// In computer programming:
// - NoteEntity (Core Data) is the heavy note locked in the desk on your device.
// - NoteDTO (Data Transfer Object) is the lightweight paper envelope!
// - It speaks JSON (the universal language of the Internet) so servers, websites,
//   and iPhones can share notes back and forth easily!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'DTO'              -> Data Transfer Object: A lightweight format made for travel.
// 2. 'Codable'          -> A superpower! Means Swift can turn this into JSON text (Encode)
//                          and turn JSON text back into a Swift object (Decode)!
// 3. 'Identifiable'     -> A badge: "I have a unique 'id', so everyone knows who I am!"
// 4. 'Equatable'        -> A rulebook: Allows checking if two envelopes are identical (note1 == note2).
// 5. 'Sendable'         -> Thread-Safe: Safe to pass across different background workers in Swift Concurrency.
// 6. 'struct'           -> A lightweight value-type blueprint.
// 7. 'UUID'             -> Universally Unique Identifier: A 36-character unique serial number.
// 8. 'JSONEncoder'      -> A machine that packages Swift structs into JSON raw bytes.
// 9. 'JSONDecoder'      -> A machine that reads JSON raw bytes and builds Swift structs.
// 10.'ISO8601'          -> The world-standard clock format for internet timestamps (e.g. "2026-08-27T16:00:00Z").
// ==============================================================================

public struct NoteDTO: Identifiable, Codable, Equatable, Sendable {
    
    // --------------------------------------------------------------------------
    // 🏷️ THE 6 FIELDS INSIDE OUR CLOUD ENVELOPE
    // --------------------------------------------------------------------------
    
    // Field 1: The unique serial number of the note
    public let id: UUID
    
    // Field 2: The headline title
    public var title: String
    
    // Field 3: The body story / content
    public var content: String
    
    // Field 4: The moment the note was first created in the cloud
    public var createdAt: Date
    
    // Field 5: The latest moment the note was updated / modified
    public var updatedAt: Date
    
    // Field 6: A version counter (1, 2, 3...) to detect edit conflicts
    public var version: Int
    
    // --------------------------------------------------------------------------
    // 🎬 CONSTRUCTOR (init)
    // --------------------------------------------------------------------------
    public init(
        id: UUID = UUID(),
        title: String,
        content: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        version: Int = 1
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.version = version
    }
}

// ==============================================================================
// 🛠️ JSON SERIALIZATION & DATE FORMATTER HELPERS
// ==============================================================================
extension NoteDTO {
    
    // Custom JSON Decoder configured with ISO8601 date parsing strategy
    public static var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    // Custom JSON Encoder configured with ISO8601 date formatting strategy
    public static var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
    
    // --------------------------------------------------------------------------
    // 🌟 SEED MOCK DATA (Initial Notes from the Remote Cloud Server)
    // --------------------------------------------------------------------------
    public static var mockSeedNotes: [NoteDTO] {
        return [
            NoteDTO(
                id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F") ?? UUID(),
                title: "☁️ Welcome to Zephyr Cloud Sync!",
                content: "This note was fetched from our Network Layer! Even if you go offline, you can edit it or make new notes. Everything will automatically sync when you reconnect.",
                createdAt: Date().addingTimeInterval(-86400 * 2),
                updatedAt: Date().addingTimeInterval(-86400 * 2),
                version: 1
            ),
            NoteDTO(
                id: UUID(uuidString: "7B2C4D8E-9A1F-4E3B-8C2D-1E5F7A9B3C5D") ?? UUID(),
                title: "🚀 Offline-First Architecture",
                content: "1. Core Data holds the local database vault.\n2. NetworkMonitor tracks Wi-Fi & Cellular.\n3. SyncEngine synchronizes the pending outbox.\n4. Background contexts ensure silky-smooth 120fps UI!",
                createdAt: Date().addingTimeInterval(-86400),
                updatedAt: Date().addingTimeInterval(-86400),
                version: 1
            ),
            NoteDTO(
                id: UUID(uuidString: "3F4A5B6C-7D8E-9F0A-1B2C-3D4E5F6A7B8C") ?? UUID(),
                title: "💡 Pro Tip: Try the Network Simulator",
                content: "Head over to the 'Sync Hub' tab to simulate turning off the internet. Create a note, then switch back to Online mode to watch the automatic background sync in action!",
                createdAt: Date().addingTimeInterval(-3600 * 4),
                updatedAt: Date().addingTimeInterval(-3600 * 4),
                version: 1
            )
        ]
    }
}
