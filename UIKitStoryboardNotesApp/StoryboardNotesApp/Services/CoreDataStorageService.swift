import CoreData

// ==============================================================================
// 🛠️ ARCHITECTURAL LAYER: [SERVICE / STORAGE]
// 📄 FILE: CoreDataStorageService.swift (for Storyboard UIKit)
// ==============================================================================
//
// 🧸 STORY TIME: THE FILING CABINET MANAGER 🗄️🔑
// ------------------------------------------------------------------------------
// Imagine you have a giant magical filing cabinet in your room where all your
// homework and secret notes are stored safely.
//
// You have ONE trusted Butler (The Storage Service) who manages the cabinet.
// Whenever NoteListViewController or NoteEditorViewController needs to read,
// create, or erase a note, they ask this exact Butler!
//
// The Butler's responsibilities:
//   1. 🚪 Open the filing cabinet (NSPersistentContainer) on launch.
//   2. 🪑 Set up a Study Desk (NSManagedObjectContext) for writing/editing in RAM.
//   3. 🔒 Save changes permanently onto the phone's flash storage with saveContext().
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'class'                  -> A blueprint for an intelligent helper object living in memory.
// 2. 'static'                 -> Belongs to the type itself; shared across the whole app.
// 3. 'let'                    -> An unchangeable constant value.
// 4. 'var'                    -> A variable value that can change over time.
// 5. 'shared' (Singleton)     -> The "One Golden Key" 🔑: Only ONE copy of this helper exists!
// 6. 'NSPersistentContainer'  -> Apple's database manager connecting our code to the disk.
// 7. 'NSManagedObjectContext' -> The "Study Desk" (scratchpad) where notes are drafted before saving.
// 8. 'init'                   -> Constructor that runs when the service helper is born.
// 9. 'do - try - catch'       -> "Safety Net": Runs a task that could fail and handles any errors.
// ==============================================================================

class CoreDataStorageService {
    
    // --------------------------------------------------------------------------
    // 🔑 1. THE ONE GOLDEN KEY (Singleton Pattern)
    // --------------------------------------------------------------------------
    // 'static let shared' is the single instance that every controller uses.
    static let shared = CoreDataStorageService()

    // --------------------------------------------------------------------------
    // 🗄️ 2. THE BIG METAL FILING CABINET (NSPersistentContainer)
    // --------------------------------------------------------------------------
    // Manages the database files on the device storage.
    let container: NSPersistentContainer

    // --------------------------------------------------------------------------
    // 🪑 3. OUR STUDY DESK (NSManagedObjectContext)
    // --------------------------------------------------------------------------
    // 'container.viewContext' is the scratchpad in memory where we create, edit,
    // and delete note cards before saving them to disk.
    var context: NSManagedObjectContext {
        return container.viewContext
    }

    // --------------------------------------------------------------------------
    // 🚪 4. OPENING THE CABINET (Initializer / init)
    // --------------------------------------------------------------------------
    // Runs when 'CoreDataStorageService.shared' is first created.
    init(inMemory: Bool = false) {
        // Step A: Point to the NoteModel database schema
        container = NSPersistentContainer(name: "NoteModel")
        
        // Step B: If inMemory is true, use temporary RAM storage
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Step C: Load and open the database store from disk
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Uh-oh! Could not open Storyboard UIKit database: \(error.localizedDescription)")
            } else {
                print("Yay! Storyboard UIKit database is open and ready to use!")
            }
        }
    }

    // --------------------------------------------------------------------------
    // 🔒 5. SAVING TO PERMANENT DISK (saveContext function)
    // --------------------------------------------------------------------------
    // Locks all note edits and additions permanently into device memory.
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("Success! Storyboard UIKit note changes were saved to permanent storage!")
            } catch {
                print("Oops! Could not save Storyboard UIKit notes: \(error.localizedDescription)")
            }
        }
    }
}
