import SwiftUI

// ==============================================================================
// 👁️ ARCHITECTURAL LAYER: [VIEW / SYNC & NETWORK HUB DIAGNOSTICS]
// 📄 FILE: SyncHubView.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE MISSION CONTROL COCKPIT 🛰️🎛️
// ------------------------------------------------------------------------------
// Welcome to the Developer & Sync Mission Control Hub!
//
// Here you can:
//   1. 🎛️ Flip the "Simulate Offline Mode" switch to test offline note creation.
//   2. 📤 See exactly which notes are currently sitting in the offline Outbox.
//   3. 📄 Inspect the raw JSON payload living in our Mock Cloud Server.
//   4. 🚀 Hit "Sync Now" to force a bi-directional synchronization cycle.
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'Toggle'           -> An ON/OFF switch.
// 2. 'Monospaced'       -> Computer code font where every letter has equal width.
// ==============================================================================

public struct SyncHubView: View {
    
    @StateObject private var viewModel = SyncHubViewModel()
    @ObservedObject private var syncEngine = SyncEngine.shared
    @ObservedObject private var networkMonitor = NetworkMonitor.shared

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                
                // SECTION 1: NETWORK SIMULATION CONTROLS
                Section(
                    header: Label("Network Simulation", systemImage: "antenna.radiowaves.left.and.right"),
                    footer: Text("Toggle 'Simulate Offline' to test offline note creation, editing, and automatic background sync without disabling your Mac/device Wi-Fi.")
                ) {
                    Toggle(isOn: Binding(
                        get: { viewModel.isSimulatingOffline },
                        set: { viewModel.setOfflineSimulation(to: $0) }
                    )) {
                        HStack {
                            Circle()
                                .fill(networkMonitor.isConnected ? Color.green : Color.red)
                                .frame(width: 10, height: 10)
                            
                            Text(networkMonitor.isConnected ? "Connection: Online" : "Connection: Simulated Offline")
                                .fontWeight(.medium)
                        }
                    }
                    
                    HStack {
                        Text("Physical Device Connection")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(networkMonitor.isRealNetworkConnected ? "Active" : "No Internet")
                            .foregroundColor(networkMonitor.isRealNetworkConnected ? .green : .red)
                    }
                    .font(.caption)
                }

                // SECTION 2: SYNC ENGINE METRICS & ACTIONS
                Section(header: Label("Sync Engine Status", systemImage: "arrow.triangle.2.circlepath")) {
                    HStack {
                        Text("Engine State")
                        Spacer()
                        if syncEngine.isSyncing {
                            HStack(spacing: 6) {
                                ProgressView().controlSize(.mini)
                                Text("Syncing...")
                                    .foregroundColor(.blue)
                            }
                        } else {
                            Text(networkMonitor.isConnected ? "Idle / Ready" : "Paused (Offline)")
                                .foregroundColor(networkMonitor.isConnected ? .green : .orange)
                        }
                    }
                    
                    HStack {
                        Text("Last Sync")
                        Spacer()
                        if let lastSync = syncEngine.lastSyncDate {
                            Text(lastSync, style: .time)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Never")
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        Text("Pending Outbox Queue")
                        Spacer()
                        Text("\(syncEngine.pendingOutboxCount) item(s)")
                            .fontWeight(.semibold)
                            .foregroundColor(syncEngine.pendingOutboxCount > 0 ? .orange : .green)
                    }

                    Button(action: {
                        Task {
                            await viewModel.triggerManualSync()
                        }
                    }) {
                        HStack {
                            Spacer()
                            Label(syncEngine.isSyncing ? "Synchronizing..." : "Sync Now (Bi-Directional)", systemImage: "arrow.triangle.2.circlepath")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(syncEngine.isSyncing || !networkMonitor.isConnected)
                }

                // SECTION 3: PENDING OUTBOX INSPECTOR
                Section(header: Label("Pending Outbox Inspector (\(viewModel.pendingNotes.count))", systemImage: "tray.and.arrow.up.fill")) {
                    if viewModel.pendingNotes.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Outbox is empty! All local notes are in sync.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    } else {
                        ForEach(viewModel.pendingNotes) { note in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(note.displayTitle)
                                        .font(.headline)
                                    Text(note.id?.uuidString ?? "No ID")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                SyncStatusBadgeView(status: note.currentSyncStatus)
                            }
                        }
                    }
                }

                // SECTION 4: MOCK SERVER RAW JSON INSPECTION
                Section(
                    header: Label("Mock Cloud Server State (JSON)", systemImage: "curlybraces"),
                    footer: Text("Live JSON data currently stored in the mock cloud server repository.")
                ) {
                    ScrollView(.horizontal, showsIndicators: true) {
                        Text(viewModel.mockServerJSON)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.primary)
                            .padding(.vertical, 4)
                    }
                    .frame(maxHeight: 180)

                    Button(role: .destructive, action: {
                        Task {
                            await viewModel.resetMockServer()
                        }
                    }) {
                        Label("Reset Cloud Server to Seed Notes", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .navigationTitle("Sync & Network Hub 🛰️")
            .onAppear {
                viewModel.refreshDiagnostics()
            }
        }
    }
}
