import SwiftUI

// ==============================================================================
// 🚀 ARCHITECTURAL LAYER: [APP ENTRY POINT]
// 📄 FILE: ZephyrNotesApp.swift
// ==============================================================================
//
// 🧸 STORY TIME: THE BIG GREEN "START" BUTTON AT THE AMUSEMENT PARK 🟢
// ------------------------------------------------------------------------------
// Imagine you are going to a huge theme park full of roller coasters and fun rides.
// When the park opens in the morning, the manager walks up to the main power box
// and presses the BIG GREEN "START" BUTTON! 🟢
//
// This file is that exact "Start Button" for Zephyr.
// When you tap the app icon on your iPhone, iOS wakes up, initializes Core Data
// and our Network Sync Engine, and presents MainTabView!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'import'      -> Brings in Apple's SwiftUI building blocks.
// 2. '@main'       -> A shiny gold sticker telling iOS: "START RUNNING HERE FIRST!"
// 3. 'struct'      -> A blueprint for creating the app structure.
// 4. ': App'       -> Adheres to Apple's official App lifecycle protocol.
// 5. 'WindowGroup' -> Creates the primary window container on the iPhone screen.
// ==============================================================================

@main
struct ZephyrNotesApp: App {
    
    init() {
        _ = CoreDataStorageService.shared
        _ = NetworkMonitor.shared
        _ = SyncEngine.shared
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
