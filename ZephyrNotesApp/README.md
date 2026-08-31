# Zephyr Notes App

A high-performance iOS note-taking application built with **SwiftUI**, **Core Data**, and an **Offline-First Network Layer with Bi-Directional Synchronization Engine**.

---

## 🌟 Architecture Overview

```
                        ┌────────────────────────────────────────┐
                        │        SwiftUI Views / Tabs            │
                        │ (Cloud Notes | Local Notes | Sync Hub) │
                        └───────────────────┬────────────────────┘
                                            │
                                            ▼
                        ┌────────────────────────────────────────┐
                        │               ViewModels               │
                        │ (SyncedListVM | NoteListVM | SyncHubVM)│
                        └───────────────────┬────────────────────┘
                                            │
                                            ▼
                        ┌────────────────────────────────────────┐
                        │             NoteRepository             │
                        │    (Single Source of Truth Facade)     │
                        └──────────┬──────────────────┬──────────┘
                                   │                  │
                    ┌──────────────▼──────┐    ┌──────▼──────────────┐
                    │ CoreDataStorage     │    │ SyncEngine          │
                    │ (Background Contexts│    │ (Outbox Push, Inbox │
                    │  & Merge Policies)  │    │  Pull, Auto-Sync)   │
                    └─────────────────────┘    └──────┬──────────────┘
                                                      │
                                               ┌──────▼──────────────┐
                                               │ NetworkService      │
                                               │ (Mock / URLSession) │
                                               └─────────────────────┘
```

---

## 🚀 Key Features & Optimizations

1. **Offline-First Synchronization (Repository Pattern)**:
   - Save immediately to local disk in `< 1ms` ensuring 120 FPS UI fluidity without network lag blocking.
   - Offline changes are stamped as `pendingCreate`, `pendingUpdate`, or `pendingDelete` (tombstones).
   - When online, changes are automatically pushed to the cloud server and remote updates are pulled.

2. **Network Connectivity & Reconnect Auto-Sync**:
   - `NetworkMonitor` utilizes Apple's `NWPathMonitor` on background queues.
   - Automatically detects reconnection transitions (Offline ➡️ Online) with reactive Combine debouncing and launches synchronization.

3. **Core Data High-Performance Optimizations**:
   - Background Managed Object Contexts (`newBackgroundContext()`) for non-blocking batch parsing and upserts.
   - `NSMergeByPropertyObjectTrumpMergePolicy` for clean in-memory conflict resolution.
   - `automaticallyMergesChangesFromParent = true` for instant UI updates when background tasks save.

4. **Multi-Tab Architecture**:
   - **Cloud Notes Tab**: Synced notes list with connectivity status bar, sync badges (`🟢 Synced`, `📤 Pending Upload`, `✏️ Pending Update`, `🗑️ Pending Deletion`), search, and pull-to-refresh.
   - **Local Notes Tab**: Classic direct Core Data experience.
   - **Sync Hub Tab**: Mission control & diagnostics dashboard with a **Network Simulator toggle** (simulate offline without turning off Mac Wi-Fi), outbox queue inspector, and live mock server raw JSON viewer.

---

## 🛠️ How to Run

1. Generate Xcode project:
   ```bash
   cd /Users/sachinkumar/Desktop/projects/ZephyrNotesApp
   xcodegen generate
   ```
2. Open `ZephyrNotesApp.xcodeproj` in Xcode.
3. Select an iOS Simulator (iOS 17+) and press **Cmd + R** (Run).
4. To test offline mode:
   - Navigate to the **Sync Hub** tab.
   - Toggle **Simulate Offline Mode** to ON.
   - Go to **Cloud Notes**, create or edit notes (they will show `Pending Upload` badges).
   - Return to **Sync Hub** and toggle **Simulate Offline Mode** to OFF.
   - Watch the automatic background sync push all pending changes to the cloud!
