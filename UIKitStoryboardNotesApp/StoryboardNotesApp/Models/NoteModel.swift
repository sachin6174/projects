import Foundation
import CoreData

// ==============================================================================
// 📦 ARCHITECTURAL LAYER: [MODEL]
// 📄 FILE: NoteModel.swift (for Storyboard UIKit)
// ==============================================================================
//
// 🧸 STORY TIME: WHAT IS A MODEL? (THE NOTE CARD BLUEPRINT) 📝✨
// ------------------------------------------------------------------------------
// Imagine you are collecting baseball cards, Pokémon cards, or recipe cards.
// Every card needs a consistent blueprint so you know what is written on it!
//
// In our Storyboard UIKit app, NoteEntity is the MODEL layer. It defines what a single
// Note Card looks like in computer memory and in Core Data permanent storage.
//
// Whether our UI is built with code or built with Storyboards (Interface Builder),
// the Model layer remains clean, pure, and independent!
//
// Each card has 4 little labeled boxes:
//   1. id        -> A unique serial number sticker (so no two notes are confused!).
//   2. title     -> The headline or topic of your note.
//   3. content   -> The full story, secret, or to-do list you typed.
//   4. timestamp -> The clock time when this note was created or saved.
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'Foundation'       -> Apple's base toolbox for strings, numbers, and dates.
// 2. 'CoreData'         -> Apple's magical database vault that saves cards permanently.
// 3. '@objc(NoteEntity)'-> Bridges our Swift code with Objective-C Core Data system.
// 4. 'public'           -> Allows any file in the project to see and use this model.
// 5. 'class'            -> Blueprint for an object living in computer memory.
// 6. 'NSManagedObject'  -> Special Apple class that knows how to save into Core Data.
// 7. '@NSManaged'       -> A magic tag: "Core Data, please manage saving this variable!"
// 8. 'UUID?'            -> Optional Unique ID code (36 letters and numbers).
// 9. 'String?'          -> Optional text characters.
// 10.'Date?'            -> Optional calendar date and clock time.
// 11.'displayTitle'     -> Helper that gives "Untitled Note" if the title was left blank.
// 12.'displayDate'      -> Helper that turns raw computer time into friendly words like "Aug 24, 2026, 1:30 AM".
// ==============================================================================

@objc(NoteEntity)
public class NoteEntity: NSManagedObject {
    
    // --------------------------------------------------------------------------
    // 🏷️ THE 4 LABELED BOXES ON OUR NOTE CARD
    // --------------------------------------------------------------------------
    
    // Box 1: A unique sticker ID so cards are never confused with each other
    @NSManaged public var id: UUID?
    
    // Box 2: The short headline or title
    @NSManaged public var title: String?
    
    // Box 3: The long story or note details
    @NSManaged public var content: String?
    
    // Box 4: The calendar date and clock time
    @NSManaged public var timestamp: Date?

    // --------------------------------------------------------------------------
    // 🎨 HELPER 1: FRIENDLY TITLE (displayTitle)
    // --------------------------------------------------------------------------
    // If a child creates a note but leaves the title blank, this helper returns
    // "Untitled Note" so the table row never looks empty or broken!
    var displayTitle: String {
        if let title = title {
            let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            if !cleanTitle.isEmpty {
                return cleanTitle
            }
        }
        return "Untitled Note"
    }

    // --------------------------------------------------------------------------
    // ⏰ HELPER 2: PRETTY DATE STAMP (displayDate)
    // --------------------------------------------------------------------------
    // Converts computer timestamp numbers into friendly human text like "Aug 24, 2026, 1:30 AM".
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // Gives "Aug 24, 2026"
        formatter.timeStyle = .short  // Gives "1:30 AM"
        return formatter.string(from: timestamp ?? Date())
    }
}
