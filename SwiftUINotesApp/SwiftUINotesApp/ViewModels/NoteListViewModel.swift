import SwiftUI
import CoreData

// ==============================================================================
// 🧠 ARCHITECTURAL LAYER: [VIEW MODEL]
// 📄 FILE: NoteListViewModel.swift
// ==============================================================================
//
// 🧸 STORY TIME: THE HELPFUL PERSONAL ASSISTANT 🧑‍💼
// ------------------------------------------------------------------------------
// Imagine you are directing a big theater show!
// - The VIEW (the screen) is the beautiful stage with pretty colors, buttons, and lights.
// - The MODEL (the database) is the quiet storage room in the basement holding raw facts.
// - The VIEW MODEL is your brilliant Personal Assistant standing in the middle!
//
// The View Model has 3 big responsibilities:
//   1. 🏃 Go down to the storage room (Core Data) and grab all the note cards.
//   2. 🧹 Organize and sort them neatly (newest notes at the very top).
//   3. 📢 Broadcast the updated notes list to the View so the screen updates instantly!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'class'            -> A blueprint for an intelligent helper object living in memory.
// 2. 'ObservableObject' -> A special badge: "I am an object that other screens can watch for news!"
// 3. '@Published'       -> The "Microphone" 🎙️: Whenever this value changes, shout to all listening
//                          views: "Hey! Look at the new data and redraw the screen!"
// 4. 'var'              -> A changeable variable holding a value or array.
// 5. 'private'          -> "Secret to this file only": Outside screens cannot touch this directly.
// 6. 'let'              -> A constant locked in stone that cannot be replaced.
// 7. 'init'             -> The constructor that runs the moment this assistant is hired.
// 8. 'NSFetchRequest'   -> An order slip sent to the database: "Please bring me all Note cards!"
// 9. 'NSSortDescriptor' -> A sorting rule: "Put the newest date on top and oldest at the bottom!"
// 10.'as?' (Type Cast)  -> "Polite Guess": Try treating the database result as a list of [NoteEntity].
// 11.'IndexSet'         -> A collection of row numbers (indexes) that the user swiped to delete.
// 12.'for ... in'       -> A loop that visits each item in a list one by one.
// ==============================================================================

class NoteListViewModel: ObservableObject {
    
    // --------------------------------------------------------------------------
    // 📢 1. THE LIVE BROADCAST MICROPHONE (@Published notes)
    // --------------------------------------------------------------------------
    // When notes change (a note is added, edited, or deleted), SwiftUI sees this
    // @Published property change and automatically redraws the list on screen!
    @Published var notes: [NoteEntity] = []

    // --------------------------------------------------------------------------
    // 🗄️ 2. PRIVATE LINK TO OUR FILING CABINET
    // --------------------------------------------------------------------------
    // We hold a reference to our shared butler (CoreDataStorageService).
    private let storageService = CoreDataStorageService.shared

    // --------------------------------------------------------------------------
    // 🎬 3. INITIALIZER (init)
    // --------------------------------------------------------------------------
    // The moment this ViewModel is created, immediately fetch all saved notes!
    init() {
        fetchNotes()
    }

    // --------------------------------------------------------------------------
    // 📥 4. FETCHING NOTES FROM DATABASE (fetchNotes)
    // --------------------------------------------------------------------------
    // 🧸 Story: Sending an order slip to the database basement to bring up all note cards.
    func fetchNotes() {
        // Step A: Create an order slip asking for NoteEntity cards
        let request = NoteEntity.fetchRequest()
        
        // Step B: Add a sorting rule -> Sort by timestamp descending (newest cards first!)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \NoteEntity.timestamp, ascending: false)
        ]
        
        // Step C: Ask our Study Desk (context) to fulfill the fetch request
        do {
            // Attempt to fetch notes and safely cast them to an array of NoteEntity
            let fetchedNotes = try storageService.context.fetch(request) as? [NoteEntity]
            
            // Step D: Put the fetched notes into our @Published array (triggers UI refresh!)
            self.notes = fetchedNotes ?? []
        } catch {
            // If fetching failed, print what went wrong
            print("Failed to fetch notes: \(error.localizedDescription)")
        }
    }

    // --------------------------------------------------------------------------
    // 🗑️ 5. DELETING NOTES (deleteNote)
    // --------------------------------------------------------------------------
    // 🧸 Story: When a user swipes a note row left and taps delete, this function runs.
    //
    // 💡 COMMON QUESTION / CLARIFICATION:
    // "If a user can only swipe one row at a time, why does this accept an IndexSet
    // and iterate with a `for` loop instead of just taking a single index?"
    //
    // 👉 REASON:
    // 1. SwiftUI's `.onDelete(perform:)` modifier always provides an `IndexSet` to support
    //    both single-row swipe-to-delete AND multi-selection mode (e.g. `EditButton()` / `EditMode`,
    //    or iPadOS/macOS multi-row selection where multiple rows can be deleted at once).
    // 2. When swiping a single row, `offsets.count == 1`, so the loop executes exactly ONCE.
    // 3. Core Data's `context.delete(_:)` only accepts one `NSManagedObject` per call.
    // 4. `storageService.saveContext()` and `fetchNotes()` are placed OUTSIDE the loop so
    //    saving to disk and reloading the UI only happen once, in a single batch transaction.
    func deleteNote(at offsets: IndexSet) {
        // Step A: Loop over every row index (runs 1 time for single swipe, or N times for multi-select)
        for index in offsets {
            let noteToDelete = notes[index]
            
            // Step B: Mark this specific note entity for deletion in the managed object context (RAM)
            storageService.context.delete(noteToDelete)
        }
        
        // Step C: Commit all deletions to permanent disk storage in ONE batch operation
        storageService.saveContext()
        
        // Step D: Refresh our notes list once so the deleted note(s) disappear from the screen!
        fetchNotes()
    }
}
