# UIKitNotesApp

A minimalist iOS note-taking application built with **UIKit** and **Core Data**, designed with modern patterns (`NSFetchedResultsController`, `UITableViewDiffableDataSource`, and programmatic Auto Layout) with minimal boilerplate.

## Architecture

- **Pattern**: Modern MVC with Reactive Diffing.
- **Persistence Layer**: [PersistenceController.swift](file:///Users/sachinkumar/Desktop/projects/UIKitNotesApp/UIKitNotesApp/CoreData/PersistenceController.swift) managing `NSPersistentContainer` and the shared `NSManagedObjectContext`.
- **Model**: `NoteEntity` ([NoteModel.xcdatamodeld](file:///Users/sachinkumar/Desktop/projects/UIKitNotesApp/UIKitNotesApp/CoreData/NoteModel.xcdatamodeld)) with convenience extensions in [NoteEntity+Extensions.swift](file:///Users/sachinkumar/Desktop/projects/UIKitNotesApp/UIKitNotesApp/Models/NoteEntity+Extensions.swift).
- **Controllers**:
  - [NoteListViewController.swift](file:///Users/sachinkumar/Desktop/projects/UIKitNotesApp/UIKitNotesApp/Controllers/NoteListViewController.swift): Integrates `NSFetchedResultsController` and `UITableViewDiffableDataSource` for reactive diffing and animated updates.
  - [NoteEditorViewController.swift](file:///Users/sachinkumar/Desktop/projects/UIKitNotesApp/UIKitNotesApp/Controllers/NoteEditorViewController.swift): Programmatic Auto Layout editor for creating and editing notes.

## Features

- **Create**: Tap `+` in navigation bar to create a note.
- **Read**: Modern list with subtitle content configuration, sorted by latest date.
- **Update**: Tap row to edit; changes persist automatically or on Done tap.
- **Delete**: Swipe left on table cell to delete.
- **Empty State**: Custom empty placeholder view when list is empty.

## How to Run

1. Open `UIKitNotesApp.xcodeproj` in Xcode.
2. Select an iOS Simulator (iOS 17+) and press **Cmd + R** (Run).
