import SwiftUI

// ==============================================================================
// 👁️ ARCHITECTURAL LAYER: [VIEW]
// 📄 FILE: NoteEditorView.swift
// ==============================================================================
//
// 🧸 STORY TIME: THE DRAWING & WRITING PAD 📝
// ------------------------------------------------------------------------------
// Imagine opening up a clean, shiny notebook where you have two special boxes:
//   1. A small box at the top to write the Title of your note.
//   2. A big wide box below it to write your secret stories, homework, or ideas!
//
// In SwiftUI MVVM architecture, NoteEditorView is the screen that draws these boxes.
// - It uses two-way bindings (the magic '$' dollar sign) to connect what your fingers
//   type directly with 'NoteEditorViewModel'.
// - When you tap the shiny "Save" button in the top right corner, it tells the
//   ViewModel to save the note and dismisses (closes) this screen so you return to the list!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'struct'                  -> A recipe/blueprint for a SwiftUI screen.
// 2. ': View'                  -> Conforms to Apple's View protocol to draw UI elements.
// 3. '@Environment(\.dismiss)' -> The "Emergency Exit Door" 🚪: A special Apple tool
//                                 that allows a screen to close itself and go back!
// 4. '@StateObject'            -> Manages our NoteEditorViewModel assistant's life cycle.
// 5. 'closure (() -> Void)?'   -> A "Walkie-Talkie Message" 📻: A block of code we call
//                                 to tell the parent list screen: "Hey, we finished saving!"
// 6. 'init'                    -> Custom constructor that creates our ViewModel with the note.
// 7. 'Form'                    -> A pretty grouped layout container (looks like iOS Settings).
// 8. 'Section'                 -> A labeled group or card inside a Form.
// 9. 'TextField'               -> A single-line box where you can type short text.
// 10.'TextEditor'              -> A big multi-line box where you can type long stories.
// 11.'$' (Binding)             -> The "Two-Way String" 🪢: Connects the text box and the
//                                 ViewModel variable so when one changes, the other updates!
// 12.'Button'                  -> A clickable button that runs code when tapped.
// ==============================================================================

struct NoteEditorView: View {
    
    // --------------------------------------------------------------------------
    // 🚪 1. THE DISMISS EXIT TOOL
    // --------------------------------------------------------------------------
    // Apple's environment value that allows us to pop/close this screen when done!
    @Environment(\.dismiss) private var dismiss

    // --------------------------------------------------------------------------
    // 🧠 2. OUR EDITOR VIEW MODEL
    // --------------------------------------------------------------------------
    // Keeps track of the text you type and handles saving to Core Data.
    @StateObject private var viewModel: NoteEditorViewModel
    
    // --------------------------------------------------------------------------
    // 📻 3. THE WALKIE-TALKIE NOTIFICATION (Callback Closure)
    // --------------------------------------------------------------------------
    // When save completes, we run 'onSave?()' to tell the main list screen to refresh!
    var onSave: (() -> Void)?

    // --------------------------------------------------------------------------
    // 🎬 4. INITIALIZER (init)
    // --------------------------------------------------------------------------
    // Parameter 'note': An existing note to edit, or nil to create a new note.
    // Parameter 'onSave': Optional closure to run after saving.
    init(note: NoteEntity?, onSave: (() -> Void)? = nil) {
        // ❌ WRONG:
        // self.viewModel = NoteEditorViewModel(note: note) // when normal variable (not @StateObject) 
        // Error: Cannot assign to property: 'viewModel' is a get-only property or uninitialized wrapper.

        // ✅ CORRECT:
        // Initialize the StateObject container itself with the wrappedValue:
        _viewModel = StateObject(wrappedValue: NoteEditorViewModel(note: note))
        self.onSave = onSave
    }


    // --------------------------------------------------------------------------
    // 🎨 5. DRAWING THE EDITOR FORM (body)
    // --------------------------------------------------------------------------
    var body: some View {
        Form {
            // Section 1: Note Title box
            Section(header: Text("Note Title")) {
                // '$viewModel.title' binds the text field directly to viewModel.title
                TextField("Enter title here...", text: $viewModel.title)
            }

            // Section 2: Note Content / Story box
            Section(header: Text("Note Content")) {
                // '$viewModel.content' binds the large text editor to viewModel.content
                TextEditor(text: $viewModel.content)
                    .frame(minHeight: 200) // Gives plenty of space to write comfortably
            }
        }
        // Shows the title in the top navigation bar (e.g. "New Note" or your typed title)
        .navigationTitle(viewModel.navigationBarTitle)
        
        // Put a "Save" button in the top right corner of the navigation toolbar
        .toolbar {
            Button("Save") {
                // Step A: Tell ViewModel to save the note to the Core Data vault
                viewModel.saveNote()
                
                // Step B: Send the walkie-talkie signal to tell the list screen to refresh
                onSave?()
                
                // Step C: Close this editor screen and slide back to the list!
                dismiss()
            }
        }
    }
}
