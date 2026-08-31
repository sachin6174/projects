import Foundation

// ==============================================================================
// 🌐 ARCHITECTURAL LAYER: [NETWORK / MOCK SERVER SIMULATOR]
// 📄 FILE: MockNetworkService.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE PLAYGROUND CLOUD SERVER ☁️🎪
// ------------------------------------------------------------------------------
// Imagine you are practicing playing soccer, but you don't have a giant stadium yet.
// So, you set up two cones in your backyard as the goal posts!
//
// MockNetworkService is our "Backyard Cloud Server"!
// It acts just like a million-dollar real-world cloud server:
//   - It stores notes in server memory.
//   - It encodes and decodes real JSON data.
//   - It simulates realistic internet lag (e.g., 0.5s network travel time).
//   - It can simulate going offline, losing connection, or having server hiccups!
//
// It allows the app to be 100% complete, fully tested, and ready to ship without
// requiring a real live backend server running right now!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'actor'            -> A Swift concurrency superhero that protects its data from
//                          data races by allowing only one task inside at a time!
// 2. 'Task.sleep'       -> Pauses the background worker for a fraction of a second to
//                          simulate realistic internet travel time across the globe.
// 3. 'nanoseconds'      -> Billions of a second (1_000_000_000 ns = 1 second).
// 4. 'JSONSerialization'-> Converts raw bytes into formatted, readable JSON strings.
// ==============================================================================

public actor MockNetworkService: NetworkServiceProtocol {
    
    // --------------------------------------------------------------------------
    // 🔑 1. SHARED SINGLETON INSTANCE
    // --------------------------------------------------------------------------
    public static let shared = MockNetworkService()

    // --------------------------------------------------------------------------
    // 💾 2. IN-MEMORY REMOTE SERVER DATABASE
    // --------------------------------------------------------------------------
    private var remoteNotes: [UUID: NoteDTO] = [:]
    
    public var simulatedLatencySeconds: Double = 0.5
    public var isSimulatingOffline: Bool = false

    // --------------------------------------------------------------------------
    // 🎬 3. INITIALIZER (Seeds Initial Server Notes)
    // --------------------------------------------------------------------------
    public init(seedNotes: [NoteDTO] = NoteDTO.mockSeedNotes) {
        for note in seedNotes {
            remoteNotes[note.id] = note
        }
        print("☁️ [MockServer] Initialized with \(remoteNotes.count) seed notes.")
    }

    // --------------------------------------------------------------------------
    // ⏳ 4. SIMULATE NETWORK DELAY & CONNECTIVITY CHECKS
    // --------------------------------------------------------------------------
    private func simulateNetworkTransport() async throws {
        if isSimulatingOffline {
            throw NetworkError.noInternetConnection
        }
        
        if simulatedLatencySeconds > 0 {
            let nanoseconds = UInt64(simulatedLatencySeconds * 1_000_000_000)
            try await Task.sleep(nanoseconds: nanoseconds)
        }
    }

    // --------------------------------------------------------------------------
    // 📥 5. FETCH ALL NOTES (GET /notes)
    // --------------------------------------------------------------------------
    public func fetchNotes() async throws -> [NoteDTO] {
        try await simulateNetworkTransport()
        
        let allNotes = Array(remoteNotes.values).sorted { $0.updatedAt > $1.updatedAt }
        
        let data = try NoteDTO.jsonEncoder.encode(allNotes)
        let decoded = try NoteDTO.jsonDecoder.decode([NoteDTO].self, from: data)
        
        print("☁️ [MockServer] GET /notes -> Returned \(decoded.count) notes.")
        return decoded
    }

    // --------------------------------------------------------------------------
    // 🔍 6. FETCH SINGLE NOTE (GET /notes/:id)
    // --------------------------------------------------------------------------
    public func fetchNote(id: UUID) async throws -> NoteDTO {
        try await simulateNetworkTransport()
        
        guard let note = remoteNotes[id] else {
            throw NetworkError.notFound(id: id)
        }
        
        let data = try NoteDTO.jsonEncoder.encode(note)
        let decoded = try NoteDTO.jsonDecoder.decode(NoteDTO.self, from: data)
        return decoded
    }

    // --------------------------------------------------------------------------
    // 📤 7. CREATE NOTE (POST /notes)
    // --------------------------------------------------------------------------
    public func createNote(_ note: NoteDTO) async throws -> NoteDTO {
        try await simulateNetworkTransport()
        
        var newNote = note
        newNote.updatedAt = Date()
        newNote.version = 1
        remoteNotes[newNote.id] = newNote
        
        print("☁️ [MockServer] POST /notes -> Created note: '\(newNote.title)' [\(newNote.id)]")
        return newNote
    }

    // --------------------------------------------------------------------------
    // ✏️ 8. UPDATE NOTE (PUT /notes/:id)
    // --------------------------------------------------------------------------
    public func updateNote(_ note: NoteDTO) async throws -> NoteDTO {
        try await simulateNetworkTransport()
        
        var updated = note
        let existingVersion = remoteNotes[note.id]?.version ?? 0
        updated.version = existingVersion + 1
        updated.updatedAt = Date()
        remoteNotes[note.id] = updated
        
        print("☁️ [MockServer] PUT /notes/\(note.id) -> Updated to v\(updated.version)")
        return updated
    }

    // --------------------------------------------------------------------------
    // 🗑️ 9. DELETE NOTE (DELETE /notes/:id)
    // --------------------------------------------------------------------------
    public func deleteNote(id: UUID) async throws {
        try await simulateNetworkTransport()
        
        remoteNotes.removeValue(forKey: id)
        print("☁️ [MockServer] DELETE /notes/\(id) -> Removed from server.")
    }

    // --------------------------------------------------------------------------
    // 📦 10. BATCH SYNC (POST /notes/batch)
    // --------------------------------------------------------------------------
    public func syncBatch(notes: [NoteDTO]) async throws -> [NoteDTO] {
        try await simulateNetworkTransport()
        
        for note in notes {
            remoteNotes[note.id] = note
        }
        
        return Array(remoteNotes.values).sorted { $0.updatedAt > $1.updatedAt }
    }

    // --------------------------------------------------------------------------
    // 🛠️ 11. DIAGNOSTIC / INSPECTOR HELPERS FOR SYNC HUB TAB
    // --------------------------------------------------------------------------
    public func getRawJSON() -> String {
        let allNotes = Array(remoteNotes.values).sorted { $0.updatedAt > $1.updatedAt }
        guard let data = try? NoteDTO.jsonEncoder.encode(allNotes),
              let jsonString = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return jsonString
    }

    public func setOfflineSimulation(_ offline: Bool) {
        self.isSimulatingOffline = offline
    }

    public func resetToSeeds() {
        remoteNotes.removeAll()
        for note in NoteDTO.mockSeedNotes {
            remoteNotes[note.id] = note
        }
    }
}
