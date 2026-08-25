import SwiftUI

// ==============================================================================
// 👁️ ARCHITECTURAL LAYER: [VIEW]
// 📄 FILE: NoteListView.swift
// ==============================================================================
//
// 🧸 STORY TIME: THE SHOPPING LIST ON THE REFRIGERATOR 📋
// ------------------------------------------------------------------------------
// Imagine you have a big magnetic board on your refrigerator where all your family
// notes and drawings hang in neat rows.
//
// In SwiftUI MVVM architecture, the VIEW is the visual screen you see and touch.
// Notice how wonderfully clean and simple this View is!
// There is ZERO database code here. It simply asks NoteListViewModel:
//   "Hey Assistant! What notes do you have for me today?"
// And it draws each note row nicely with a bold title and a tiny clock date.
//
// When you tap a note or swipe to delete, the View whispers to the ViewModel:
//   "The user swiped row #2, please handle the deletion!"
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'struct'          -> A lightweight blueprint for building a UI component.
// 2. ': View'          -> Tells SwiftUI this struct draws visual pixels on the screen.
// 3. '@StateObject'    -> The "Boss Guardian" 👑: Creates the ViewModel and keeps it alive
//                         in memory as long as this screen is showing.
// 4. 'NavigationStack' -> A magic slide projector: lets you slide smoothly to detail screens
//                         and back with a top title bar and back button.
// 5. 'List'            -> A vertically scrolling list (like a shopping list or table).
// 6. 'ForEach'         -> A loop that draws one row for every single note card in our list.
// 7. 'NavigationLink'  -> A button that, when tapped, navigates (slides) to another screen!
// 8. 'VStack'          -> Vertical Stack: Stacks elements on top of each other (like pancakes 🥞).
// 9. 'Text'            -> Draws readable letters, words, and emojis on the screen.
// 10.'.onDelete'       -> A listener waiting for you to swipe a row to the left to delete it.
// 11.'.navigationTitle'-> Puts a big bold title at the very top of the navigation bar.
// 12.'.overlay'        -> Places a layer directly on top (like a sticker or empty placeholder).
// 13.'.toolbar'        -> Adds buttons (like the '+' add button) into the navigation bar.
// 14.'.onAppear'       -> A sensor that fires whenever this screen appears in front of your eyes.
// ==============================================================================

struct NoteListView: View {
    
    // --------------------------------------------------------------------------
    // 🧠 1. CONNECTING TO OUR ASSISTANT (ViewModel)
    // --------------------------------------------------------------------------
    // '@StateObject' tells SwiftUI: "Create our NoteListViewModel assistant and
    // keep it alive as long as this screen is visible!"
    @StateObject private var viewModel = NoteListViewModel()

    // --------------------------------------------------------------------------
    // 🎨 2. DRAWING THE SCREEN (body)
    // --------------------------------------------------------------------------
    var body: some View {
        // NavigationStack gives us a top navigation bar and allows sliding to detail screens
        NavigationStack {
            
            // List provides the scrolling container for all our note rows
            List {
                // ForEach draws one row for every note card in our viewModel.notes array
                ForEach(viewModel.notes) { note in
                    
                    // NavigationLink turns the entire row into a tappable button
                    // that opens up the NoteEditorView for this specific note!
                    NavigationLink(destination: NoteEditorView(note: note, onSave: {
                        // When the child finishes editing and saves, refresh the list!
                        viewModel.fetchNotes()
                    })) {
                        // VStack stacks the Title and Date vertically on top of each other
                        VStack(alignment: .leading, spacing: 4) {
                            
                            // Bold headline title (using our friendly displayTitle helper)
                            Text(note.displayTitle)
                                .font(.headline)
                            
                            // Small gray date stamp (using our friendly displayDate helper)
                            Text(note.displayDate)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                // When a child swipes a row to the left to delete, tell the ViewModel!
                .onDelete { offsets in
                    viewModel.deleteNote(at: offsets)
                }
            }
            // The big bold title shown at the top of the screen
            .navigationTitle("My Notes")
            
            // If there are no notes yet, show a friendly helper message in the center
            .overlay {
                if viewModel.notes.isEmpty {
                    Text("No notes yet.\nTap '+' to create one.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                }
            }
            
            // Put a '+' plus icon button in the top navigation bar to write a new note
            .toolbar {
                NavigationLink(destination: NoteEditorView(note: nil, onSave: {
                    // When a brand new note is created and saved, refresh the list!
                    viewModel.fetchNotes()
                })) {
                    Image(systemName: "plus")
                }
            }
            // .onAppear triggers every time this screen becomes visible to fetch the freshest notes!
            .onAppear {
                viewModel.fetchNotes()
            }
        }
    }
}
