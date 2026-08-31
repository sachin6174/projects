import UIKit

// ==============================================================================
// 🎮 ARCHITECTURAL LAYER: [CONTROLLER]
// 📄 FILE: NoteListViewController.swift (for Storyboard UIKit)
// ==============================================================================
//
// 🧸 STORY TIME: THE THEATER DIRECTOR WITH A STORYBOARD SCRIPT! 🎬🎭🎨
// ------------------------------------------------------------------------------
// In Storyboard UIKit, a 'UIViewController' is like a director directing a play,
// but with a big visual illustrated comic book (Main.storyboard) already drawn!
//
// Instead of building every wooden wall and table by writing code by hand:
//   1. 🎨 The Storyboard draws the screen visually in Interface Builder.
//   2. 🔌 An '@IBOutlet' is an electric cable plugging the visual UITableView from
//      the storyboard directly into our controller's brain!
//   3. 🎬 A 'UIStoryboardSegue' (The Magical Train Track 🚂) connects our list screen
//      to the editor screen when we tap '+' or tap a note row!
//   4. 👨‍🍳 The Controller still wears the "Chef Hat" (UITableViewDataSource) to serve data.
//   5. 👮 The Controller still wears the "Guard Hat" (UITableViewDelegate) to handle swipes and taps.
//   6. 📥 Talks to CoreDataStorageService to fetch notes from the database vault.
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'UIViewController'        -> Apple's base director class for managing a full screen.
// 2. '@IBOutlet'               -> The "Electric Cable" 🔌: Plugs a visual UI element from
//                                 the Storyboard directly into our Swift code variable!
// 3. 'weak'                    -> A gentle grip: Prevents memory retention cycles between objects.
// 4. 'UITableView'             -> A scrolling list view that shows rows of information.
// 5. 'UITableViewDataSource'   -> The "Chef" protocol: provides data and cells to the table.
// 6. 'UITableViewDelegate'     -> The "Guard" protocol: detects taps, selections, and swipes.
// 7. 'UIStoryboardSegue'       -> The "Magical Train" 🚂: Manages animated travel between two screens.
// 8. 'prepare(for:sender:)'    -> "Packing Your Backpack" 🎒: Gives you a chance to put data
//                                 onto the train before it leaves for the next screen!
// 9. 'override'                -> "I am customizing a standard Apple function with my own recipe!"
// 10.'super'                   -> "Hey parent class! Do your standard Apple setup first!"
// 11.'viewDidLoad()'           -> Runs ONCE when this screen is first created from the storyboard.
// 12.'viewWillAppear()'        -> Runs EVERY TIME this screen is about to appear before your eyes.
// 13.'dequeueReusableCell'     -> The "Recycling Bin" ♻️: Re-uses row views so the phone stays
//                                 super fast and never runs out of memory while scrolling!
// 14.'indexPath'               -> The exact address of a row (section number + row number).
// ==============================================================================

class NoteListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // --------------------------------------------------------------------------
    // 🔌 1. STORYBOARD OUTLETS (Visual Props Wired from Main.storyboard)
    // --------------------------------------------------------------------------
    
    // Electric cable plugged into the UITableView drawn on Main.storyboard
    @IBOutlet weak var tableView: UITableView!
    
    // --------------------------------------------------------------------------
    // 📦 2. PROPS & DATA (Our Note Cards)
    // --------------------------------------------------------------------------
    
    // Our backpack (array) holding all the NoteEntity cards fetched from Core Data
    var notes: [NoteEntity] = []

    // MARK: - Lifecycle Functions

    // --------------------------------------------------------------------------
    // 🎬 3. SCREEN INITIAL SETUP (viewDidLoad)
    // --------------------------------------------------------------------------
    // Runs ONCE when this controller is unpacked from the storyboard.
    override func viewDidLoad() {
        // Step A: Let Apple's UIViewController do its base setup
        super.viewDidLoad()
        
        // Step B: Set the headline title
        title = "My Notes"

        // Step C: Ensure table view data source and delegate are connected to self
        // (Also wired in the Storyboard connections panel!)
        tableView.dataSource = self
        tableView.delegate = self
    }

    // --------------------------------------------------------------------------
    // 👁️ 4. REFRESH ON SCREEN APPEAR (viewWillAppear)
    // --------------------------------------------------------------------------
    // Runs EVERY TIME the screen comes into view (e.g. after returning from editor).
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload all notes from Core Data so any new or edited notes show up!
        loadNotesFromDatabase()
    }

    // MARK: - Core Data Fetching

    // --------------------------------------------------------------------------
    // 📥 5. FETCHING NOTES FROM DATABASE (loadNotesFromDatabase)
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

    // MARK: - 🚂 Storyboard Segue Navigation (Packing the Backpack)

    // --------------------------------------------------------------------------
    // 🚂 6. PREPARING FOR SEGUE TRANSITION (prepare(for:sender:))
    // --------------------------------------------------------------------------
    // When a segue is triggered in the Storyboard (tapping '+' or tapping a row),
    // iOS calls this function right before sliding to the NoteEditorViewController!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Scenario A: Tapping an existing note row (Train identifier: "showEditNote")
        if segue.identifier == "showEditNote",
           let editorVC = segue.destination as? NoteEditorViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            
            // Pass the tapped note card into the editor screen's backpack!
            editorVC.note = notes[indexPath.row]
            
            // Deselect the row so it returns to white cleanly
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        // Scenario B: Tapping the '+' button (Train identifier: "showAddNote")
        else if segue.identifier == "showAddNote",
                let editorVC = segue.destination as? NoteEditorViewController {
            
            // For a new note, we pass nil so the editor opens with blank boxes!
            editorVC.note = nil
        }
    }

    // MARK: - 👨‍🍳 UITableViewDataSource (The Chef answering table questions)

    // --------------------------------------------------------------------------
    // 🔢 7. ROW COUNT QUESTION
    // --------------------------------------------------------------------------
    // Question: "Chef, how many note rows should we draw on screen?"
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the exact number of note cards in our notes array
        return notes.count
    }

    // --------------------------------------------------------------------------
    // 🎨 8. ROW CELL CONFIGURATION QUESTION
    // --------------------------------------------------------------------------
    // Question: "Chef, what should row number 'X' look like?"
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Grab a prototype cell from the storyboard recycling bin!
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
