import SwiftUI

// ==============================================================================
// 👁️ ARCHITECTURAL LAYER: [VIEW / CLOUD SYNCED NOTES LIST]
// 📄 FILE: SyncedNoteListView.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE CLOUD-CONNECTED NOTEBOOK 📖☁️
// ------------------------------------------------------------------------------
// Imagine opening a special magical notebook.
//
// At the top of the screen:
//   - A glowing banner tells you if you are connected to the Cloud or working Offline.
//
// In the list below:
//   - Every note card has a little colorful sticker showing if it is already in the
//     cloud (🟢 Synced) or waiting in your backpack to be sent (📤 Pending Upload).
//
// If you pull down from the top of the list:
//   - The phone reaches up into the sky to fetch the newest notes from the server!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. '.searchable'            -> Adds a modern iOS search bar right inside the navigation bar.
// 2. '.refreshable'           -> Enables pull-to-refresh gesture natively.
// 3. 'ProgressView'           -> A rotating activity spinner indicating background work.
// 4. 'ContentUnavailableView' -> Modern iOS 17 view for empty lists or zero search results.
// ==============================================================================

public struct SyncedNoteListView: View {
    
    @StateObject private var viewModel = SyncedNoteListViewModel()
    @ObservedObject private var syncEngine = SyncEngine.shared
    @ObservedObject private var networkMonitor = NetworkMonitor.shared
    
    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Connectivity & Sync Status Banner
                connectivityBanner
                
                // Notes List
                List {
                    ForEach(viewModel.filteredNotes) { note in
                        NavigationLink(destination: SyncedNoteEditorView(note: note, onSave: {
                            viewModel.fetchNotes()
                        })) {
                            NoteRowView(note: note)
                        }
                    }
                    .onDelete { offsets in
                        viewModel.deleteNote(at: offsets)
                    }
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    await viewModel.triggerManualSync()
                }
                .overlay {
                    if viewModel.notes.isEmpty {
                        emptyStateView
                    } else if viewModel.filteredNotes.isEmpty {
                        ContentUnavailableView.search(text: viewModel.searchText)
                    }
                }
            }
            .navigationTitle("Zephyr Cloud Notes ☁️")
            .searchable(text: $viewModel.searchText, prompt: "Search synced notes...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        Task {
                            await viewModel.triggerManualSync()
                        }
                    }) {
                        if syncEngine.isSyncing {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                    }
                    .disabled(syncEngine.isSyncing || !networkMonitor.isConnected)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SyncedNoteEditorView(note: nil, onSave: {
                        viewModel.fetchNotes()
                    })) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
            }
            .onAppear {
                viewModel.fetchNotes()
            }
        }
    }

    private var connectivityBanner: some View {
        HStack(spacing: 8) {
            if !networkMonitor.isConnected {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.orange)
                Text("Offline Mode — Notes save locally & sync when reconnected")
                    .font(.caption)
                    .foregroundColor(.orange)
            } else if syncEngine.isSyncing {
                ProgressView()
                    .controlSize(.mini)
                Text("Syncing notes with cloud server...")
                    .font(.caption)
                    .foregroundColor(.blue)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                if let lastSync = syncEngine.lastSyncDate {
                    Text("Synced with Cloud • \(lastSync, style: .time)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Connected to Cloud")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()

            if syncEngine.pendingOutboxCount > 0 {
                Text("\(syncEngine.pendingOutboxCount) queued")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.orange)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemBackground))
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Cloud Notes Yet", systemImage: "icloud.and.arrow.up")
        } description: {
            Text("Create a note or pull down to fetch notes from the cloud server.")
        } actions: {
            Button("Fetch from Cloud") {
                Task {
                    await viewModel.triggerManualSync()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

private struct NoteRowView: View {
    let note: NoteEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                Text(note.displayTitle)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                SyncStatusBadgeView(status: note.currentSyncStatus)
            }
            
            Text(note.displaySnippet)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text(note.displayDate)
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                if note.serverVersion > 0 {
                    Text("• v\(note.serverVersion)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
