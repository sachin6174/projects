import Foundation
import CoreData

// ==============================================================================
// 📦 ARCHITECTURAL LAYER: [MODEL]
// 📄 FILE: NoteModel.swift (for SwiftUI)
// ==============================================================================
//
// 🧸 STORY TIME: WHAT IS A MODEL? (THE NOTE CARD BLUEPRINT)
// ------------------------------------------------------------------------------
// Imagine you are making a super cool recipe book or collecting superhero cards.
// Before you can make any card, you need a blueprint! You need to decide:
// "What information belongs on every single card in our collection?"
//
// In our app, the MODEL is the blueprint for a single Note Card.
// Every single note card has 4 little labeled boxes where we store information:
//   1. id        -> A unique serial number sticker (so no two cards get mixed up!).
//   2. title     -> The headline or topic of your note (e.g. "My Secret Diary").
//   3. content   -> The full story, secret, or to-do list you typed.
//   4. timestamp -> The clock time when this note was created or edited.
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'Foundation'       -> Apple's basic toolkit for dealing with numbers, dates, & text.
// 2. 'CoreData'         -> Apple's super-secure magic vault for saving data to the hard drive.
// 3. '@objc(NoteEntity)'-> A bridge tag telling older Apple systems the name of our entity.
// 4. 'public'           -> "Everyone is allowed to see and use this blueprint!"
// 5. 'class'            -> A blueprint for creating objects that live in computer memory.
// 6. 'NSManagedObject'  -> A special Core Data object that knows how to live in the database vault.
// 7. 'Identifiable'     -> A badge that says: "Every note has a unique ID, so SwiftUI can tell them apart!"
// 8. '@NSManaged'       -> A magic tag: "Hey Core Data! Save and load this box automatically!"
// 9. 'var'              -> A variable box whose contents can change over time.
// 10. '?' (Optional)    -> The "Mystery Question Mark": means the box might hold data OR be empty (nil)!
// 11. 'UUID'            -> Universally Unique Identifier: A 36-letter code that is 1-of-a-kind in the world!
// 12. 'String'          -> Text made of letters, words, emojis, or numbers inside quotes.
// 13. 'Date'            -> A point on the calendar clock (day, month, year, hour, minute, second).
// 14. 'DateFormatter'   -> A magical translation machine that turns computer dates into pretty human words.
// 15. '??' (Coalescing) -> "Safety Net": If the value on the left is missing/empty, use the value on the right!
// ==============================================================================

@objc(NoteEntity)
public class NoteEntity: NSManagedObject, Identifiable {
    
    // --------------------------------------------------------------------------
    // 🏷️ THE 4 LABELED BOXES ON OUR NOTE CARD
    // --------------------------------------------------------------------------
    
    // Box 1: A unique sticker ID so SwiftUI never confuses two notes
    // Type: UUID? (An optional unique code)
    @NSManaged public var id: UUID?
    
    // Box 2: The short headline or title of the note
    // Type: String? (An optional text string)
    @NSManaged public var title: String?
    
    // Box 3: The long paragraph, secret story, or list of chores
    // Type: String? (An optional text string)
    @NSManaged public var content: String?
    
    // Box 4: The exact calendar date and clock time
    // Type: Date? (An optional clock date)
    @NSManaged public var timestamp: Date?

    // --------------------------------------------------------------------------
    // 🎨 HELPER 1: FRIENDLY TITLE (displayTitle)
    // --------------------------------------------------------------------------
    // 🧸 Story: What if a child creates a note but forgets to type a title?
    // We do NOT want the screen to look broken or blank!
    // This computed property checks if you typed a title.
    // If you typed one, it uses your title. If you left it empty, it returns "Untitled Note"!
    var displayTitle: String {
        // Step A: Unwrap the optional 'title' box to see if text exists inside
        if let title = title {
            // Step B: Trim away any accidental empty spaces or newlines at start/end
            let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Step C: If there is still real text left, return it proudly!
            if !cleanTitle.isEmpty {
                return cleanTitle
            }
        }
        
        // Step D: If the box was empty or just spaces, give a friendly default title!
        return "Untitled Note"
    }

    // --------------------------------------------------------------------------
    // ⏰ HELPER 2: PRETTY DATE STAMP (displayDate)
    // --------------------------------------------------------------------------
    // 🧸 Story: Computers store time as huge confusing numbers (like 745829103.542 seconds).
    // Humans love reading friendly dates like "Aug 24, 2026, 1:30 AM".
    // This helper runs the computer date through a translator to make it beautiful!
    var displayDate: String {
        // Step A: Create our date translation machine (DateFormatter)
        let formatter = DateFormatter()
        
        // Step B: Choose the date style -> .medium gives us e.g. "Aug 24, 2026"
        formatter.dateStyle = .medium
        
        // Step C: Choose the time style -> .short gives us e.g. "1:30 AM"
        formatter.timeStyle = .short
        
        // Step D: If timestamp is nil, use our safety net (??) to use right now: Date()
        let dateToFormat = timestamp ?? Date()
        
        // Step E: Ask the translation machine to turn the date into a friendly String!
        return formatter.string(from: dateToFormat)
    }
}
