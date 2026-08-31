import UIKit

// ==============================================================================
// 🎮 ARCHITECTURAL LAYER: [CONTROLLER]
// 📄 FILE: NoteEditorViewController.swift (for Storyboard UIKit)
// ==============================================================================
//
// 🧸 STORY TIME: THE NOTE WRITING DESK DESIGNED IN INTERFACE BUILDER 📝🎨
// ------------------------------------------------------------------------------
// Imagine you drew your dream arts & crafts writing desk in an art sketchbook!
//
// In Storyboard UIKit:
//   1. 🎨 The layout (Title Box, Paper Box, and Safe Area Constraints) was visually
//      drawn in Main.storyboard (Interface Builder).
//   2. 🔌 Two '@IBOutlet' cables plug those visual boxes directly into 'titleTextField'
//      and 'contentTextView' so Swift can read and write text into them.
//   3. ⚡ An '@IBAction' is a special doorbell wire: When the child taps the visual
//      "Save" button in the navigation bar, it instantly rings our 'saveNoteTapped' function!
//   4. 💾 When rung, the 5-step save flow packs up the note card, locks it into
//      Core Data storage, and pops back to the list screen!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'UIViewController'        -> Apple's base screen director.
// 2. '@IBOutlet'               -> The "Input Cable" 🔌: Connects visual text fields from
//                                 the Storyboard canvas into our Swift code properties.
// 3. '@IBAction'               -> The "Action Doorbell" ⚡: Connects button taps on the
//                                 Storyboard canvas into a Swift function that gets executed!
// 4. 'UITextField'             -> A single-line text input box for short titles.
// 5. 'UITextView'              -> A multi-line scrollable text box for big paragraphs.
// 6. 'weak'                    -> A gentle reference to prevent retain cycles.
// 7. 'layer.cornerRadius'      -> Rounds the sharp corners of a box into smooth curves.
// 8. 'layer.borderColor'       -> Paints a neat outline border around a box.
// 9. 'popViewController'       -> Slides the current screen off the stage to go back to the previous screen.
// ==============================================================================

class NoteEditorViewController: UIViewController {
    
    // --------------------------------------------------------------------------
    // 🔌 1. STORYBOARD OUTLETS (Visual Props Wired from Main.storyboard)
    // --------------------------------------------------------------------------
    
    // Electric cable connected to the Title text field on the storyboard canvas
    @IBOutlet weak var titleTextField: UITextField!
    
    // Electric cable connected to the Content text view on the storyboard canvas
    @IBOutlet weak var contentTextView: UITextView!

    // --------------------------------------------------------------------------
    // 📦 2. THE NOTE CARD WE ARE HOLDING
    // --------------------------------------------------------------------------
    // If nil: We are creating a BRAND NEW note!
    // If not nil: We are EDITING an existing note card.
    var note: NoteEntity?

    // MARK: - Lifecycle Functions

    // --------------------------------------------------------------------------
    // 🎬 3. SCREEN SETUP (viewDidLoad)
    // --------------------------------------------------------------------------
    // Runs ONCE when this screen is unpacked from Main.storyboard.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Stage Title: If we have no note, title it "New Note"; otherwise "Edit Note"
        title = note == nil ? "New Note" : "Edit Note"

        // Polish the content text view border and corner radius
        setupTextViewStyling()
        
        // If editing an existing note, pre-fill the boxes with the saved words!
        loadNoteData()
    }

    // MARK: - UI Polish

    // --------------------------------------------------------------------------
    // 🎨 4. TEXT VIEW STYLING (setupTextViewStyling)
    // --------------------------------------------------------------------------
    // Adds a delicate border and rounded corners to the note paper area
    func setupTextViewStyling() {
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.systemGray4.cgColor
        contentTextView.layer.cornerRadius = 8
    }

    // MARK: - Loading Existing Note Words

    // --------------------------------------------------------------------------
    // 📖 5. PRE-FILLING SAVED DATA (loadNoteData)
    // --------------------------------------------------------------------------
    func loadNoteData() {
        // If we passed an old note, put its saved title and content into the text boxes
        if let note = note {
            titleTextField.text = note.title
            contentTextView.text = note.content
        }
    }

    // MARK: - 💾 The 5-Step Save Flow (@IBAction)

    // --------------------------------------------------------------------------
    // ⚡ 6. SAVING THE NOTE (@IBAction saveNoteTapped)
    // --------------------------------------------------------------------------
    // Connected directly to the "Save" bar button in Main.storyboard.
    // Rings automatically when the child taps "Save"!
    @IBAction func saveNoteTapped(_ sender: Any) {
        let storageService = CoreDataStorageService.shared
        let context = storageService.context

        // Step 1: Decide if we update an existing card or create a brand new one
        let noteToSave: NoteEntity
        if let existingNote = note {
            noteToSave = existingNote
        } else {
            noteToSave = NoteEntity(context: context)
            noteToSave.id = UUID() // Give new notes a fresh unique ID sticker!
        }

        // Step 2: Write the user's typed words onto the note card
        noteToSave.title = titleTextField.text
        noteToSave.content = contentTextView.text
        noteToSave.timestamp = Date() // Stamp with current clock time!

        // Step 3: Lock the note card into permanent storage
        storageService.saveContext()

        // Step 4: Close this editor stage and slide back to the notes list!
        navigationController?.popViewController(animated: true)
    }
}
