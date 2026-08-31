import SwiftUI

// ==============================================================================
// 👁️ ARCHITECTURAL LAYER: [VIEW / REUSABLE UI COMPONENT]
// 📄 FILE: SyncStatusBadgeView.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE STATUS BADGE STICKER 🏷️✨
// ------------------------------------------------------------------------------
// Imagine you have colorful glowing stickers for your note cards:
//   - 🟢 Green Cloud: "Safely synced in the cloud!"
//   - 📤 Blue Arrow: "Uploaded pending!"
//   - ✏️ Orange Pencil: "Edited offline, waiting to sync!"
//   - 🗑️ Red Cross: "Deleted offline, waiting to clean on server!"
//
// This reusable SwiftUI view draws that chic glowing pill badge!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'Capsule'          -> A rounded pill shape.
// 2. 'HStack'           -> Horizontal Stack.
// ==============================================================================

public struct SyncStatusBadgeView: View {
    
    public let status: SyncStatus
    
    public init(status: SyncStatus) {
        self.status = status
    }
    
    private var badgeColor: Color {
        switch status {
        case .synced:
            return .green
        case .pendingCreate:
            return .blue
        case .pendingUpdate:
            return .orange
        case .pendingDelete:
            return .red
        }
    }
    
    private var iconName: String {
        switch status {
        case .synced:
            return "checkmark.icloud.fill"
        case .pendingCreate:
            return "arrow.up.icloud.fill"
        case .pendingUpdate:
            return "arrow.triangle.2.circlepath.icloud.fill"
        case .pendingDelete:
            return "xmark.icloud.fill"
        }
    }
    
    private var labelText: String {
        switch status {
        case .synced:
            return "Synced"
        case .pendingCreate:
            return "Pending Upload"
        case .pendingUpdate:
            return "Pending Update"
        case .pendingDelete:
            return "Pending Deletion"
        }
    }

    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.system(size: 10, weight: .bold))
            
            Text(labelText)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(badgeColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeColor.opacity(0.12))
        .clipShape(Capsule())
    }
}
