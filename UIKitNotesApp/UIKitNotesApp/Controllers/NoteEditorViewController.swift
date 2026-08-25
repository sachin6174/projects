import UIKit

// ==============================================================================
// 🎮 ARCHITECTURAL LAYER: [CONTROLLER]
// 📄 FILE: NoteEditorViewController.swift
// ==============================================================================
//
// 🧸 STORY TIME: THE NOTE WRITING DESK (Editor Controller in UIKit) 📝🎨
// ------------------------------------------------------------------------------
// Imagine you are sitting at your arts & crafts table ready to write a letter
// to your best friend!
//
// This Controller is in charge of setting up your writing desk:
//   1. 🏷️ Places a single-line Title Box (UITextField) at the top for the headline.
//   2. 📜 Places a big scrollable Paper Box (UITextView) below it for your story.
//   3. 🪢 Fastens invisible rubber bands (Auto Layout Constraints) so the boxes
//      never slide around or fall off the screen on any iPhone or iPad.
//   4. 💾 When you tap the shiny "Save" button, it packs up your note, locks it
//      into Core Data, and slides back to the list screen!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'UIViewController'                    -> Apple's base screen director.
// 2. 'UITextField'                         -> A single-line text input box for short titles.
// 3. 'UITextView'                          -> A multi-line scrollable text box for big paragraphs.
// 4. 'Auto Layout'                         -> Invisible rubber bands (constraints) pinning boxes in place!
// 5. 'translatesAutoresizingMaskIntoConstraints = false'
//                                          -> Tells iOS: "Don't use old automatic sizing; use our Auto Layout rules!"
// 6. 'NSLayoutConstraint.activate'         -> Fastens all the rubber bands onto the stage at once!
// 7. 'safeAreaLayoutGuide'                 -> The safe area of the screen avoiding the notch and home bar.
// 8. 'ternary operator (a ? b : c)'        -> "Quick Question": If 'a' is true, pick 'b'; otherwise pick 'c'!
// 9. 'popViewController'                   -> Slides the current screen off the stage to go back to the previous screen.
// ==============================================================================

class NoteEditorViewController: UIViewController {
    
    // --------------------------------------------------------------------------
    // 📦 1. THE NOTE CARD WE ARE HOLDING
    // --------------------------------------------------------------------------
    // If nil: We are creating a BRAND NEW note!
    // If not nil: We are EDITING an existing note card.
    var note: NoteEntity?

    // --------------------------------------------------------------------------
    // 🎨 2. UI PROPS ON THE STAGE
    // --------------------------------------------------------------------------
    // Single-line text field for typing the title
    let titleTextField = UITextField()
    
    // Multi-line scrollable text box for typing paragraphs and stories
    let contentTextView = UITextView()

    // MARK: - Lifecycle Functions

    // --------------------------------------------------------------------------
    // 🎬 3. SCREEN SETUP (viewDidLoad)
    // --------------------------------------------------------------------------
    // Runs ONCE when this screen is first created.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground // Clean background matching light/dark mode
        
        // Stage Title: If we have no note, title it "New Note"; otherwise "Edit Note"
        title = note == nil ? "New Note" : "Edit Note"

        // Place a shiny "Save" button in the top right corner of the navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(saveNote) // When tapped, runs our saveNote() function below!
        )

        // Place our text boxes on the screen and anchor them with Auto Layout
        setupViews()
        
        // If editing an existing note, pre-fill the boxes with the old words!
        loadNoteData()
    }

    // MARK: - Auto Layout Setup (Invisible Rubber Bands)

    // --------------------------------------------------------------------------
    // 🪢 4. POSITIONING UI ELEMENTS (setupViews)
    // --------------------------------------------------------------------------
    // Pins our text boxes to the screen so they look gorgeous on every device size!
    func setupViews() {
        // Step 1: Decorate and add the title text field
        titleTextField.placeholder = "Note Title"
        titleTextField.font = .boldSystemFont(ofSize: 20)
        titleTextField.borderStyle = .roundedRect // Rounded border corners
        titleTextField.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
        view.addSubview(titleTextField)

        // Step 2: Decorate and add the content text view
        contentTextView.font = .systemFont(ofSize: 16)
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.systemGray4.cgColor // Light gray outline border
        contentTextView.layer.cornerRadius = 8                       // Rounded smooth corners
        contentTextView.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
        view.addSubview(contentTextView)

        // Step 3: Fasten the invisible rubber bands (Constraints)
        NSLayoutConstraint.activate([
            // Title field: Pinned 16 points below top safe area, and 16 points from left & right edges
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 44), // Standard touchable height

            // Content text view: Sits 16 points below the title field, filling all remaining space
            contentTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
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

    // MARK: - 💾 The 5-Step Save Flow

    // --------------------------------------------------------------------------
    // 💾 6. SAVING THE NOTE (saveNote)
    // --------------------------------------------------------------------------
    // Runs when the child taps the "Save" button in the top right corner.
    @objc func saveNote() {
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
