import SwiftUI
import CoreData

// ==============================================================================
// 🧠 ARCHITECTURAL LAYER: [VIEW MODEL]
// 📄 FILE: NoteEditorViewModel.swift
// ==============================================================================
//
// 🧸 STORY TIME: THE NOTE-WRITING ASSISTANT ✍️
// ------------------------------------------------------------------------------
// Imagine you are sitting down at your drawing desk with a brand new blank paper
// (or an old drawing you want to finish).
//
// This ViewModel is your dedicated Writing Assistant!
// While your fingers type on the screen, this assistant:
//   1. 📝 Catches every letter you type in the Title and Content boxes in real time.
//   2. 🏷️ Updates the top title bar so it shows the title you just wrote!
//   3. 💾 Executes the 5-step recipe to save your note safely into Core Data!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'class'            -> A blueprint for an intelligent helper object living in memory.
// 2. 'ObservableObject' -> A badge telling SwiftUI: "Keep an eye on me for changes!"
// 3. '@Published'       -> The "Live Wire": Whenever you type a letter, SwiftUI instantly
//                          receives the new text so everything stays synchronized!
// 4. 'var'              -> A changeable variable box.
// 5. 'let'              -> A constant locked in stone that cannot be changed.
// 6. 'private'          -> Hidden inside this helper; outside screens cannot touch it directly.
// 7. 'nil'              -> "Empty / Nothing / No note attached yet".
// 8. 'init'             -> Constructor that runs when the editor assistant is created.
// 9. 'UUID()'           -> Creates a brand new 1-in-a-billion unique serial number sticker.
// 10.'Date()'           -> Grabs the exact current second from the iPhone's clock.
// 11.'self'             -> "Me! This specific helper object!"
// ==============================================================================

class NoteEditorViewModel: ObservableObject {
    
    // --------------------------------------------------------------------------
    // 📦 1. THE NOTE CARD BEING EDITED
    // --------------------------------------------------------------------------
    // If this is nil: The child wants to create a BRAND NEW note!
    // If this holds a NoteEntity: The child is EDITING an existing saved note.
    private var note: NoteEntity?
    
    // Reference to our shared Core Data filing cabinet service
    private let storageService = CoreDataStorageService.shared

    // --------------------------------------------------------------------------
    // 📝 2. REAL-TIME TEXT FIELDS BOUND TO THE SCREEN (@Published)
    // --------------------------------------------------------------------------
    // Every time the keyboard types a letter, these @Published boxes update immediately:
    
    // Holds the title text
    @Published var title: String = ""
    
    // Holds the long content / story text
    @Published var content: String = ""

    // --------------------------------------------------------------------------
    // 🏷️ 3. TOP NAVIGATION BAR TITLE HELPER
    // --------------------------------------------------------------------------
    // If the title box is completely empty, show "New Note" at the top of the screen.
    // As soon as the child types something, show their typed title up top!
    var navigationBarTitle: String {
        if title.isEmpty {
            return "New Note"
        } else {
            return title
        }
    }

    // --------------------------------------------------------------------------
    // 🎬 4. INITIALIZER (init)
    // --------------------------------------------------------------------------
    // Parameter 'note': An existing note card, or nil if creating a new note.
    init(note: NoteEntity? = nil) {
        self.note = note
        
        // If we are editing an existing note, pre-fill the text boxes with its saved words!
        if let note = note {
            self.title = note.title ?? ""
            self.content = note.content ?? ""
        }
    }

    // --------------------------------------------------------------------------
    // 💾 5. THE 5-STEP SAVE RECIPE (saveNote)
    // --------------------------------------------------------------------------
    // 🧸 Story: Packaging the typed words onto a note card and locking it in the vault.
    func saveNote() {
        let context = storageService.context

        // Step 1: Decide if we update an existing card or create a brand new one
        let noteToSave: NoteEntity
        if let existingNote = note {
            // Re-use the existing card we are editing
            noteToSave = existingNote
        } else {
            // Create a brand new NoteEntity card on our Study Desk (context)
            noteToSave = NoteEntity(context: context)
            // Give the new note card a brand new unique serial number sticker!
            noteToSave.id = UUID()
        }

        // Step 2: Copy the user's typed title and content onto the card
        noteToSave.title = title
        noteToSave.content = content
        
        // Step 3: Stamp the card with the current date & clock time
        noteToSave.timestamp = Date()

        // Step 4: Lock all changes into permanent disk storage!
        storageService.saveContext()
    }
}
