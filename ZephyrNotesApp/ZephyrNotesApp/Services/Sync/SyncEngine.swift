import Foundation
import CoreData
import Combine
import SwiftUI

// ==============================================================================
// 🔄 ARCHITECTURAL LAYER: [SYNC ENGINE / COORDINATOR]
// 📄 FILE: SyncEngine.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE AIRPORT TRAFFIC CONTROLLER 🛫🛬
// ------------------------------------------------------------------------------
// Imagine you are managing a busy airport with dozens of planes arriving
// and departing every minute!
//
// In Zephyr, the SyncEngine is our Air Traffic Controller:
//   1. 🛫 Outbox Departures: Local planes (notes you created or edited offline)
//      are safely launched up into the Cloud Server.
//   2. 🛬 Inbox Arrivals: Cloud planes (new notes added from other devices)
//      land smoothly and unpack into your local Core Data database.
//   3. ⚡ Conflict Avoidance: If two planes try to land on the same runway,
//      the controller compares timestamps and versions so nothing crashes!
//   4. 🟢 Auto-Resume: The moment runway fog clears (Internet reconnects),
//      the controller immediately launches all queued planes automatically!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'SyncEngine'       -> The master coordinator running bi-directional data flow.
// 2. 'Outbox'           -> The queue of pending changes created while offline.
// 3. 'Inbox'            -> The stream of fresh notes downloaded from the cloud.
// 4. 'Debounce'         -> "Wait until the dust settles": Avoids spamming sync if connection flickers.
// 5. 'Tombstone'        -> A soft-deleted record that tells the server: "Please delete me too!"
// ==============================================================================

@MainActor
public class SyncEngine: ObservableObject {
    
    // --------------------------------------------------------------------------
    // 🔑 1. SHARED SINGLETON INSTANCE
    // --------------------------------------------------------------------------
    public static let shared = SyncEngine()

    // --------------------------------------------------------------------------
    // 📢 2. PUBLISHED SYNC METRICS (Observed by UI)
    // --------------------------------------------------------------------------
    
    @Published public private(set) var isSyncing: Bool = false
    @Published public private(set) var lastSyncDate: Date?
    @Published public private(set) var pendingOutboxCount: Int = 0
    @Published public private(set) var syncErrorMessage: String?

    // --------------------------------------------------------------------------
    // 🛠️ 3. DEPENDENCIES
    // --------------------------------------------------------------------------
    private let storageService: CoreDataStorageService
    public let networkService: NetworkServiceProtocol
    private let networkMonitor: NetworkMonitor
    private var cancellables = Set<AnyCancellable>()

    // --------------------------------------------------------------------------
    // 🎬 4. INITIALIZER
    // --------------------------------------------------------------------------
    public init(
        storageService: CoreDataStorageService = .shared,
        networkService: NetworkServiceProtocol = MockNetworkService.shared,
        networkMonitor: NetworkMonitor = .shared
    ) {
        self.storageService = storageService
        self.networkService = networkService
        self.networkMonitor = networkMonitor
        
        updatePendingOutboxCount()
        setupAutoSyncOnReconnect()
    }

    // --------------------------------------------------------------------------
    // 🔄 5. REFRESH PENDING OUTBOX COUNT
    // --------------------------------------------------------------------------
    public func updatePendingOutboxCount() {
        let pending = storageService.fetchPendingSyncNotes()
        self.pendingOutboxCount = pending.count
    }

    // --------------------------------------------------------------------------
    // 🟢 6. AUTO-SYNC ON RECONNECT (Combine Reactive Listener)
    // --------------------------------------------------------------------------
    private func setupAutoSyncOnReconnect() {
        Publishers.CombineLatest(networkMonitor.$isRealNetworkConnected, networkMonitor.$isSimulatingOffline)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] isReal, isSimulated in
                guard let self = self else { return }
                let isConnected = isReal && !isSimulated
                if isConnected {
                    print("🔄 [SyncEngine] Connection detected online! Triggering automatic background sync...")
                    Task {
                        await self.performSync()
                    }
                }
            }
            .store(in: &cancellables)
    }

    // --------------------------------------------------------------------------
    // 🚀 7. MASTER SYNC FUNCTION (Bi-Directional)
    // --------------------------------------------------------------------------
    public func performSync() async {
        guard networkMonitor.isConnected else {
            print("⚠️ [SyncEngine] Cannot sync: Device is currently OFFLINE.")
            self.syncErrorMessage = "Offline: Changes are saved locally."
            updatePendingOutboxCount()
            return
        }
        
        guard !isSyncing else {
            print("⏳ [SyncEngine] Sync already in progress, skipping duplicate call.")
            return
        }

        self.isSyncing = true
        self.syncErrorMessage = nil

        print("🚀 [SyncEngine] Starting bi-directional sync...")

        do {
            // STEP 1: PUSH OUTBOX (Local changes -> Remote Server)
            try await pushOutboxToRemote()

            // STEP 2: PULL INBOX (Remote Server -> Local Core Data)
            try await pullInboxFromRemote()

            // STEP 3: MARK SYNC SUCCESS
            self.lastSyncDate = Date()
            self.updatePendingOutboxCount()
            self.isSyncing = false
            print("🎉 [SyncEngine] Bi-directional sync completed successfully at \(Date())!")
        } catch {
            self.syncErrorMessage = error.localizedDescription
            self.isSyncing = false
            self.updatePendingOutboxCount()
            print("❌ [SyncEngine] Sync failed with error: \(error.localizedDescription)")
        }
    }

    // --------------------------------------------------------------------------
    // 🛫 8. PUSH OUTBOX TO REMOTE (Process Pending Local Changes)
    // --------------------------------------------------------------------------
    private func pushOutboxToRemote() async throws {
        let pendingNotes = storageService.fetchPendingSyncNotes()
        print("🛫 [SyncEngine] Processing \(pendingNotes.count) pending outbox notes...")

        for note in pendingNotes {
            guard let id = note.id else { continue }
            
            switch note.currentSyncStatus {
            case .pendingCreate:
                let dto = note.toDTO()
                let createdDTO = try await networkService.createNote(dto)
                note.update(from: createdDTO)
                
            case .pendingUpdate:
                let dto = note.toDTO()
                let updatedDTO = try await networkService.updateNote(dto)
                note.update(from: updatedDTO)
                
            case .pendingDelete:
                try await networkService.deleteNote(id: id)
                storageService.permanentlyDeleteNote(id: id)
                
            case .synced:
                break
            }
        }
        
        storageService.saveContext()
    }

    // --------------------------------------------------------------------------
    // 🛬 9. PULL INBOX FROM REMOTE (Fetch & Batch Upsert in Background)
    // --------------------------------------------------------------------------
    private func pullInboxFromRemote() async throws {
        print("🛬 [SyncEngine] Fetching latest notes from cloud server...")
        let remoteNotes = try await networkService.fetchNotes()
        
        return try await withCheckedThrowingContinuation { continuation in
            storageService.batchUpsert(dtos: remoteNotes) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
