import SwiftUI

// ==============================================================================
// 🚀 ARCHITECTURAL LAYER: [APP ENTRY POINT]
// 📄 FILE: SwiftUINotesApp.swift
// ==============================================================================
//
// 🧸 STORY TIME: THE BIG GREEN "START" BUTTON AT THE AMUSEMENT PARK
// ------------------------------------------------------------------------------
// Imagine you are going to a huge theme park full of roller coasters and fun rides.
// When the park opens in the morning, the manager walks up to the main power box
// and presses the BIG GREEN "START" BUTTON! 🟢
//
// This file is that exact "Start Button" for our entire iPhone app.
// When you tap our app's icon on your iPhone screen, iOS looks for this exact file
// to know how to wake up, build a shiny window, and put our Note List on the screen!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'import'   -> Like opening a toy box! It tells the computer: "Hey! Bring in
//                  all the pre-made Apple tools so we can build buttons and screens!"
// 2. 'SwiftUI'  -> Apple's modern magical building blocks (Lego kit) for making UI.
// 3. '@main'    -> A shiny gold sticker that tells iPhone: "START RUNNING HERE FIRST!"
// 4. 'struct'   -> A blueprint or recipe card used to build a structure or object.
// 5. ': App'    -> Tells Swift this struct follows the official Apple "App Rules".
// 6. 'var'      -> Short for "variable" - a labeled box or property that holds value.
// 7. 'body'     -> The main contents inside our structure (what it's made of).
// 8. 'some'     -> An opaque type: "I promise to give you some kind of Scene!"
// 9. 'Scene'    -> A big container (like the glass screen on your phone) showing content.
// 10.'WindowGroup' -> A special window manager that holds and displays our app screens.
// ==============================================================================

// Step 1: Tell iOS where the journey begins with the @main gold sticker!
@main
struct SwiftUINotesApp: App {
    
    // Step 2: 'body' describes what visual scene should open up on the phone
    var body: some Scene {
        
        // Step 3: 'WindowGroup' creates the main window on the device
        WindowGroup {
            
            // Step 4: Show our NoteListView (our notes list screen) as the first screen!
            NoteListView()
        }
    }
}
