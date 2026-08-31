import SwiftUI
import CoreData
import Combine

// ==============================================================================
// 🧠 ARCHITECTURAL LAYER: [VIEW MODEL / CLOUD SYNCED NOTES]
// 📄 FILE: SyncedNoteListViewModel.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE CLOUD-CONNECTED EXECUTIVE ASSISTANT 🧑‍💻☁️
// ------------------------------------------------------------------------------
// This ViewModel is our high-tech, cloud-connected Executive Assistant!
//
// It has 4 super responsibilities:
//   1. 📱 Read all notes from the local Core Data filing vault.
//   2. 🔍 Instant Search: Filter notes instantly as you type in the search bar.
//   3. 🔄 Pull-to-Refresh: When you swipe down on the screen, it asks SyncEngine
//      to perform a full cloud synchronization!
//   4. 📡 Status Observer: Keeps track of online/offline status and sync badges
//      so the user always knows the exact state of their data.
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'ObservableObject' -> Broadcasts changes to SwiftUI so views redraw themselves.
// 2. '@Published'       -> The megaphone that shouts when variables change.
// 3. 'searchText'       -> Real-time query string entered in the search bar.
// 4. 'Pull-to-Refresh'  -> Swiping down at the top of a list to trigger a fresh sync.
// ==============================================================================

@MainActor
public class SyncedNoteListViewModel: ObservableObject {
    
    // --------------------------------------------------------------------------
    // 📢 1. PUBLISHED STATE PROPERTIES
    // --------------------------------------------------------------------------
    @Published public var notes: [NoteEntity] = []
    @Published public var searchText: String = ""
    
    public let repository: NoteRepositoryProtocol
    public let syncEngine: SyncEngine
    public let networkMonitor: NetworkMonitor
    
    private var cancellables = Set<AnyCancellable>()

    // --------------------------------------------------------------------------
    // 🔍 2. FILTERED NOTES COMPUTED PROPERTY
    // --------------------------------------------------------------------------
    public var filteredNotes: [NoteEntity] {
        let cleanQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanQuery.isEmpty else {
            return notes
        }
        return notes.filter { note in
            let titleMatch = note.displayTitle.localizedCaseInsensitiveContains(cleanQuery)
            let contentMatch = (note.content ?? "").localizedCaseInsensitiveContains(cleanQuery)
            return titleMatch || contentMatch
        }
    }

    // --------------------------------------------------------------------------
    // 🎬 3. INITIALIZER
    // --------------------------------------------------------------------------
    public init(
        repository: NoteRepositoryProtocol = NoteRepository.shared,
        syncEngine: SyncEngine = .shared,
        networkMonitor: NetworkMonitor = .shared
    ) {
        self.repository = repository
        self.syncEngine = syncEngine
        self.networkMonitor = networkMonitor
        
        fetchNotes()
        bindSyncEngine()
    }

    // --------------------------------------------------------------------------
    // 🔗 4. BIND TO SYNC ENGINE UPDATES
    // --------------------------------------------------------------------------
    private func bindSyncEngine() {
        syncEngine.$lastSyncDate
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.fetchNotes()
            }
            .store(in: &cancellables)
    }

    // --------------------------------------------------------------------------
    // 📥 5. FETCH NOTES FROM LOCAL REPOSITORY
    // --------------------------------------------------------------------------
    public func fetchNotes() {
        self.notes = repository.getNotes()
    }

    // --------------------------------------------------------------------------
    // 🔄 6. PULL-TO-REFRESH & MANUAL SYNC TRIGGER
    // --------------------------------------------------------------------------
    public func triggerManualSync() async {
        await repository.sync()
        fetchNotes()
    }

    // --------------------------------------------------------------------------
    // 🗑️ 7. DELETE NOTES (Supports Offline Soft-Delete & Cloud Sync)
    // --------------------------------------------------------------------------
    public func deleteNote(at offsets: IndexSet) {
        let currentFiltered = filteredNotes
        for index in offsets {
            guard index < currentFiltered.count else { continue }
            let noteToDelete = currentFiltered[index]
            Task {
                try? await repository.deleteNote(noteToDelete)
                fetchNotes()
            }
        }
    }
}
