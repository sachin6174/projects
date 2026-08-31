import SwiftUI
import CoreData
import Combine

// ==============================================================================
// 🧠 ARCHITECTURAL LAYER: [VIEW MODEL / SYNC HUB & DIAGNOSTICS]
// 📄 FILE: SyncHubViewModel.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE MISSION CONTROL DASHBOARD 🛰️📊
// ------------------------------------------------------------------------------
// Imagine NASA's Mission Control room with giant glowing monitors tracking rockets!
//
// In Zephyr, SyncHubViewModel is our app's Mission Control!
// It gives developers, testers, and curious users superpowers to:
//   1. 🎛️ Flip the Simulated Offline switch to test how the app behaves without Wi-Fi.
//   2. 📤 Inspect every single note waiting in the pending Outbox queue.
//   3. 📄 View the raw live JSON data returned by the Mock Cloud Server.
//   4. ⚡ Trigger manual bi-directional synchronization with one tap.
//   5. 🔄 Reset the server back to original seed data or clear local test data.
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'Diagnostics'      -> Tools used to check health, inspect data, and test edge cases.
// 2. 'Outbox Queue'     -> Notes waiting on the runway to be uploaded when internet returns.
// ==============================================================================

@MainActor
public class SyncHubViewModel: ObservableObject {
    
    // --------------------------------------------------------------------------
    // 📢 1. PUBLISHED STATE
    // --------------------------------------------------------------------------
    @Published public var pendingNotes: [NoteEntity] = []
    @Published public var mockServerJSON: String = ""
    @Published public var isSimulatingOffline: Bool = false
    
    public let syncEngine: SyncEngine
    public let networkMonitor: NetworkMonitor
    private let storageService: CoreDataStorageService
    private var cancellables = Set<AnyCancellable>()

    // --------------------------------------------------------------------------
    // 🎬 2. INITIALIZER
    // --------------------------------------------------------------------------
    public init(
        syncEngine: SyncEngine = .shared,
        networkMonitor: NetworkMonitor = .shared,
        storageService: CoreDataStorageService = .shared
    ) {
        self.syncEngine = syncEngine
        self.networkMonitor = networkMonitor
        self.storageService = storageService
        self.isSimulatingOffline = networkMonitor.isSimulatingOffline
        
        bindState()
        refreshDiagnostics()
    }

    // --------------------------------------------------------------------------
    // 🔗 3. BINDING STATE
    // --------------------------------------------------------------------------
    private func bindState() {
        networkMonitor.$isSimulatingOffline
            .receive(on: RunLoop.main)
            .sink { [weak self] isSimulated in
                self?.isSimulatingOffline = isSimulated
            }
            .store(in: &cancellables)

        syncEngine.$lastSyncDate
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshDiagnostics()
            }
            .store(in: &cancellables)
    }

    // --------------------------------------------------------------------------
    // 🔄 4. REFRESH DIAGNOSTIC DATA
    // --------------------------------------------------------------------------
    public func refreshDiagnostics() {
        self.pendingNotes = storageService.fetchPendingSyncNotes()
        Task {
            if let mock = syncEngine.networkService as? MockNetworkService {
                self.mockServerJSON = await mock.getRawJSON()
            }
        }
    }

    // --------------------------------------------------------------------------
    // 🎛️ 5. TOGGLE SIMULATED OFFLINE MODE
    // --------------------------------------------------------------------------
    public func setOfflineSimulation(to offline: Bool) {
        networkMonitor.isSimulatingOffline = offline
        self.isSimulatingOffline = offline
    }

    // --------------------------------------------------------------------------
    // 🚀 6. TRIGGER MANUAL FULL SYNC
    // --------------------------------------------------------------------------
    public func triggerManualSync() async {
        await syncEngine.performSync()
        refreshDiagnostics()
    }

    // --------------------------------------------------------------------------
    // 🔄 7. RESET MOCK SERVER TO SEED NOTES
    // --------------------------------------------------------------------------
    public func resetMockServer() async {
        if let mock = syncEngine.networkService as? MockNetworkService {
            await mock.resetToSeeds()
            await syncEngine.performSync()
            refreshDiagnostics()
        }
    }
}
