# SwiftUINotesApp

A minimalist iOS note-taking application built with **SwiftUI** and **Core Data**, designed with clean architecture and minimal boilerplate.

## Architecture

- **Pattern**: MVVM / SwiftUI idiomatic architecture.
- **Persistence Layer**: [PersistenceController.swift](file:///Users/sachinkumar/Desktop/projects/SwiftUINotesApp/SwiftUINotesApp/CoreData/PersistenceController.swift) managing `NSPersistentContainer` and the shared `NSManagedObjectContext`.
- **Model**: `NoteEntity` ([NoteModel.xcdatamodeld](file:///Users/sachinkumar/Desktop/projects/SwiftUINotesApp/SwiftUINotesApp/CoreData/NoteModel.xcdatamodeld)) with convenience extensions in [NoteEntity+Extensions.swift](file:///Users/sachinkumar/Desktop/projects/SwiftUINotesApp/SwiftUINotesApp/Models/NoteEntity+Extensions.swift).
- **Reactive UI**: 
  - `@FetchRequest` in [NoteListView.swift](file:///Users/sachinkumar/Desktop/projects/SwiftUINotesApp/SwiftUINotesApp/Views/NoteListView.swift) for zero-boilerplate reactive UI synchronization.
  - [NoteEditorView.swift](file:///Users/sachinkumar/Desktop/projects/SwiftUINotesApp/SwiftUINotesApp/Views/NoteEditorView.swift) for creating and editing notes.

## Features

- **Create**: Add new notes with title and content.
- **Read**: Dynamic list sorted by latest timestamp.
- **Update**: Tap any note to open the editor and update title or content.
- **Delete**: Native swipe-to-delete support.
- **Empty State**: Native `ContentUnavailableView` for empty state.

## How to Run

1. Open `SwiftUINotesApp.xcodeproj` in Xcode.
2. Select an iOS Simulator (iOS 17+) and press **Cmd + R** (Run).
