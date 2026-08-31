import UIKit

// ==============================================================================
// 🎮 ARCHITECTURAL LAYER: [CONTROLLER]
// 📄 FILE: NoteListViewController.swift
// ==============================================================================
//
// 🧸 STORY TIME: THE THEATER DIRECTOR (Main Screen Controller) 🎬🎭
// ------------------------------------------------------------------------------
// In UIKit MVC (Model-View-Controller) architecture, a 'UIViewController' is like
// the director of a play on a theater stage!
//
// The Director manages everything on screen:
//   1. 📜 Builds the UITableView (the long scrolling shopping list).
//   2. 👨‍🍳 Wears the "Chef Hat" (UITableViewDataSource) to tell the table
//      how many note rows to draw and what text to put on each row.
//   3. 👮 Wears the "Guard Hat" (UITableViewDelegate) to watch for when you tap a row
//      or swipe left to delete a note!
//   4. 📥 Talks to CoreDataStorageService to fetch notes from the database vault.
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'UIViewController'        -> Apple's base director class for managing a full screen.
// 2. 'UITableView'             -> A scrolling list view that shows rows of information.
// 3. 'UITableViewDataSource'   -> The "Chef" protocol: provides data and cells to the table.
// 4. 'UITableViewDelegate'     -> The "Guard" protocol: detects taps, selections, and swipes.
// 5. 'override'                -> "I am customizing a standard Apple function with my own recipe!"
// 6. 'super'                   -> "Hey parent class! Do your standard Apple setup first!"
// 7. 'viewDidLoad()'           -> Runs ONCE when this screen is first created in memory.
// 8. 'viewWillAppear()'        -> Runs EVERY TIME this screen is about to appear before your eyes.
// 9. '@objc'                   -> Tells Swift to make this method visible to Objective-C buttons.
// 10.'#selector'               -> Points a button to the exact function it should trigger when tapped.
// 11.'dequeueReusableCell'     -> The "Recycling Bin" ♻️: Re-uses row views so the phone stays
//                                 super fast and never runs out of memory while scrolling!
// 12.'indexPath'               -> The exact address of a row (section number + row number).
// 13.'navigationController'    -> The slide projector that pushes and pops screens with animations.
// ==============================================================================

class NoteListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // --------------------------------------------------------------------------
    // 📦 1. PROPS & DATA (Our Stage Props)
    // --------------------------------------------------------------------------
    
    // The scrolling table view component that displays all note rows
    let tableView = UITableView()
    
    // Our backpack (array) holding all the NoteEntity cards fetched from Core Data
    var notes: [NoteEntity] = []

    // MARK: - Lifecycle Functions

    // --------------------------------------------------------------------------
    // 🎬 2. SCREEN INITIAL SETUP (viewDidLoad)
    // --------------------------------------------------------------------------
    // Runs ONCE when this controller is first loaded into memory.
    override func viewDidLoad() {
        // Step A: Let Apple's UIViewController do its base setup
        super.viewDidLoad()
        
        // Step B: Set the headline title and background color
        title = "My Notes"
        view.backgroundColor = .systemBackground

        // Step C: Add a friendly "+" button in the top right navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewNote) // Tapping '+' runs addNewNote() below!
        )

        // Step D: Setup table view sizing to fill the entire screen
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Step E: Assign this controller as the DataSource (Chef) and Delegate (Guard)
        tableView.dataSource = self
        tableView.delegate = self
        
        // Step F: Register standard UITableViewCell for row recycling
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Step G: Add the table view onto the screen stage!
        view.addSubview(tableView)
    }

    // --------------------------------------------------------------------------
    // 👁️ 3. REFRESH ON SCREEN APPEAR (viewWillAppear)
    // --------------------------------------------------------------------------
    // Runs EVERY TIME the screen comes into view (e.g. after returning from editor).
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload all notes from Core Data so any new or edited notes show up!
        loadNotesFromDatabase()
    }

    // MARK: - Core Data Fetching

    // --------------------------------------------------------------------------
    // 📥 4. FETCHING NOTES FROM DATABASE (loadNotesFromDatabase)
    // --------------------------------------------------------------------------
    func loadNotesFromDatabase() {
        // Step 1: Write an order slip asking for NoteEntity cards
        let request = NoteEntity.fetchRequest()
        
        // Step 2: Sort notes by timestamp, newest cards on top (ascending: false)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \NoteEntity.timestamp, ascending: false)
        ]
        
        // Step 3: Fetch cards from the Core Data context into our notes array
        notes = (try? CoreDataStorageService.shared.context.fetch(request) as? [NoteEntity]) ?? []
        
        // Step 4: Tell the table view: "Hey! We have fresh notes! Redraw all rows!"
        tableView.reloadData()
    }

    // MARK: - User Actions

    // --------------------------------------------------------------------------
    // ➕ 5. ADDING A NEW NOTE (addNewNote)
    // --------------------------------------------------------------------------
    // Called when the child taps the "+" button in the top navigation bar.
    @objc func addNewNote() {
        // Create an empty editor screen and slide it onto the stage
        let editorScreen = NoteEditorViewController()
        navigationController?.pushViewController(editorScreen, animated: true)
    }

    // MARK: - 👨‍🍳 UITableViewDataSource (The Chef answering table questions)

    // --------------------------------------------------------------------------
    // 🔢 6. ROW COUNT QUESTION
    // --------------------------------------------------------------------------
    // Question: "Chef, how many note rows should we draw on screen?"
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the exact number of note cards in our notes array
        return notes.count
    }

    // --------------------------------------------------------------------------
    // 🎨 7. ROW CELL CONFIGURATION QUESTION
    // --------------------------------------------------------------------------
    // Question: "Chef, what should row number 'X' look like?"
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Grab a recycled cell so the phone stays super fast!
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Grab the note card at this row position
        let note = notes[indexPath.row]

        // Configure the text content of the cell
        var content = cell.defaultContentConfiguration()
        content.text = note.displayTitle          // Bold title at the top
        content.secondaryText = note.displayDate  // Smaller subtitle date below it
        cell.contentConfiguration = content
        
        // Add a small gray arrow on the right side indicating the row is tappable
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - 👮 UITableViewDelegate (The Guard watching touches)

    // --------------------------------------------------------------------------
    // 👆 8. ROW TAP SELECTION (didSelectRowAt)
    // --------------------------------------------------------------------------
    // Triggered when the child taps on a note card row!
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Un-highlight the row so it turns back from gray to white smoothly
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Find which note card was tapped
        let selectedNote = notes[indexPath.row]
        
        // Open the editor screen pre-filled with this note's saved words!
        let editorScreen = NoteEditorViewController()
        editorScreen.note = selectedNote
        navigationController?.pushViewController(editorScreen, animated: true)
    }

    // --------------------------------------------------------------------------
    // 🗑️ 9. SWIPE TO DELETE (commit editingStyle)
    // --------------------------------------------------------------------------
    // Triggered when the child swipes a row to the left and taps Delete!
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            // Find which note card was swiped
            let noteToDelete = notes[indexPath.row]
            
            // Step A: Tell our Study Desk (context) to delete this note
            CoreDataStorageService.shared.context.delete(noteToDelete)
            
            // Step B: Save changes permanently to the database vault
            CoreDataStorageService.shared.saveContext()
            
            // Step C: Reload notes from database so the deleted row disappears!
            loadNotesFromDatabase()
        }
    }
}
