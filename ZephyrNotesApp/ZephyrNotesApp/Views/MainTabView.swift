import SwiftUI

// ==============================================================================
// 👁️ ARCHITECTURAL LAYER: [VIEW / ROOT TAB NAVIGATION]
// 📄 FILE: MainTabView.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE MULTI-ROOM NOTE CLUBHOUSE 🏰📑
// ------------------------------------------------------------------------------
// Imagine your treehouse has 3 wonderful rooms:
//   1. ☁️ Room 1: The Sky Observatory ("Cloud Notes") -> Offline-First Network Sync!
//   2. 📝 Room 2: The Local Desk ("Local Notes") -> Classic Core Data storage!
//   3. 🛰️ Room 3: Mission Control ("Sync Hub") -> Network Simulator & JSON Inspector!
//
// MainTabView creates the bottom navigation bar so you can hop between
// rooms with a single tap!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'TabView'          -> A bottom navigation bar with icons and labels for each screen.
// 2. '.tabItem'         -> The icon and label that appears on the bottom bar for that tab.
// 3. '.badge'           -> A little badge notification number on a tab bar item.
// ==============================================================================

public struct MainTabView: View {
    
    @ObservedObject private var syncEngine = SyncEngine.shared
    @State private var selectedTab: Int = 1

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            
            // TAB 1: CLOUD SYNCED NOTES (Offline-First + Network Layer)
            SyncedNoteListView()
                .tabItem {
                    Label("Cloud Notes", systemImage: "icloud.fill")
                }
                .tag(1)

            // TAB 2: LOCAL NOTES (Direct Core Data Standalone)
            NoteListView()
                .tabItem {
                    Label("Local Notes", systemImage: "note.text")
                }
                .tag(2)

            // TAB 3: SYNC & NETWORK HUB (Diagnostics & Network Simulator)
            SyncHubView()
                .tabItem {
                    Label("Sync Hub", systemImage: "antenna.radiowaves.left.and.right")
                }
                .badge(syncEngine.pendingOutboxCount > 0 ? "\(syncEngine.pendingOutboxCount)" : nil)
                .tag(3)
        }
    }
}
