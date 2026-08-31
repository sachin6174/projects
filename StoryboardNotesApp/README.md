# StoryboardNotesApp

A minimalist iOS note-taking application built with **UIKit**, **Storyboards (Interface Builder)**, and **Core Data**, featuring `@IBOutlet`, `@IBAction`, prototype cells, and `UIStoryboardSegue` transitions.

---

## Architecture: Storyboard UIKit vs Programmatic UIKit

| Layer / Feature | Programmatic UIKit (`UIKitNotesApp`) | Storyboard UIKit (`StoryboardNotesApp`) |
| :--- | :--- | :--- |
| **UI Layout** | Pure Swift code (`setupViews()`, `NSLayoutConstraint.activate`) | `Main.storyboard` (XML layout rendered in Interface Builder) |
| **View Binding** | Instantiated programmatically | `@IBOutlet weak var ...` wired to Storyboard elements |
| **User Events** | Add target `#selector(...)` | `@IBAction func ...` wired to Storyboard bar buttons |
| **Navigation** | `navigationController?.pushViewController(...)` | `UIStoryboardSegue` (`showAddNote`, `showEditNote`) |
| **Cell Template** | `tableView.register(UITableViewCell.self, ...)` | Prototype cell in `Main.storyboard` with ID `"cell"` |
| **Window Setup** | Manual `UIWindow` initialization in `SceneDelegate` | Automated instantiation of Initial View Controller |

---

## Project Structure

```
StoryboardNotesApp/
├── project.yml                                              # XcodeGen project specification
├── README.md                                                # Project documentation
└── StoryboardNotesApp/
    ├── App/
    │   ├── AppDelegate.swift                               # App lifecycle controller
    │   └── SceneDelegate.swift                             # UI scene delegate
    ├── Controllers/
    │   ├── NoteListViewController.swift                    # Table view list with @IBOutlet and Segues
    │   └── NoteEditorViewController.swift                  # Note editor with @IBOutlet and @IBAction
    ├── Models/
    │   ├── NoteModel.swift                                 # NoteEntity class & display helpers
    │   └── NoteModel.xcdatamodeld/                         # Core Data schema
    ├── Services/
    │   └── CoreDataStorageService.swift                    # Singleton persistence manager
    └── Resources/
        └── Base.lproj/
            ├── Main.storyboard                             # Visual scene layouts & segues
            └── LaunchScreen.storyboard                     # Launch screen
```

---

## Features

- **Create**: Tap `+` in the navigation bar to trigger the `showAddNote` segue.
- **Read**: Dynamic `UITableView` displaying prototype cells with `title` and `subtitle` (formatted date).
- **Update**: Tap any note row to trigger the `showEditNote` segue, which pre-fills the editor.
- **Delete**: Swipe left on any note cell to delete from Core Data and refresh the list.
- **Persistence**: Managed through `CoreDataStorageService` (`NSPersistentContainer` / `NSManagedObjectContext`).

---

## How to Run

1. Open `StoryboardNotesApp.xcodeproj` in Xcode.
2. Select an iOS Simulator (iOS 17+) and press **Cmd + R** (Run).
