import CoreData

// ==============================================================================
// 🛠️ ARCHITECTURAL LAYER: [SERVICE / STORAGE]
// 📄 FILE: CoreDataStorageService.swift (for SwiftUI)
// ==============================================================================
//
// 🧸 STORY TIME: THE FAITHFUL FILING CABINET MANAGER 🗄️
// ------------------------------------------------------------------------------
// Imagine you have a giant magical filing cabinet in your playroom where you keep
// all your favorite drawings and notes.
//
// You don't want every kid running into the room and kicking the cabinet open.
// Instead, you hire ONE super-smart, faithful Butler called the "Storage Service".
//
// This Service has 3 big jobs:
//   1. 🚪 Open the cabinet (NSPersistentContainer) when the app starts.
//   2. 🪑 Set up a clean Study Desk (NSManagedObjectContext) where we can draft notes.
//   3. 🔒 Lock all our notes safely onto the device disk when we call saveContext()!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'class'                  -> A blueprint for an intelligent helper object in memory.
// 2. 'static'                 -> Belongs to the whole class itself, not just one instance.
// 3. 'let'                    -> A constant value locked in stone! It can never change once set.
// 4. 'var'                    -> A flexible variable that can change whenever needed.
// 5. 'shared' (Singleton)     -> The "One Golden Key": only ONE instance exists for the whole app!
// 6. 'NSPersistentContainer'  -> Apple's big metal filing cabinet that holds database files on disk.
// 7. 'NSManagedObjectContext' -> The "Study Desk" (scratchpad in RAM) where we write and edit notes.
// 8. 'init'                   -> The "Birth Certificate" constructor that runs when the helper is born.
// 9. 'Bool'                   -> A true/false switch (like a light switch: ON or OFF).
// 10.'closure { ... }'        -> A mini block of instructions passed like a package to run later.
// 11.'if let' (Optional Bind) -> "Peek Inside the Box": if data exists inside, safely use it!
// 12.'func'                   -> Short for "function" - a set recipe of actions that can be triggered.
// 13.'hasChanges'             -> A quick check: "Did anything new get written or erased on our desk?"
// 14.'do - try - catch'       -> "Attempt with a Safety Net": Try doing something risky, and if it fails,
//                               catch the error without crashing the app!
// ==============================================================================

class CoreDataStorageService {
    
    // --------------------------------------------------------------------------
    // 🔑 1. THE ONE GOLDEN KEY (Singleton Pattern)
    // --------------------------------------------------------------------------
    // 'static let shared' creates a single shared instance of our butler.
    // Every view and viewModel in the app talks to this exact same helper!
    static let shared = CoreDataStorageService()

    // --------------------------------------------------------------------------
    // 🗄️ 2. THE BIG METAL FILING CABINET (NSPersistentContainer)
    // --------------------------------------------------------------------------
    // This container manages the actual database file saved on your phone.
    let container: NSPersistentContainer

    // --------------------------------------------------------------------------
    // 🪑 3. OUR STUDY DESK / SCRATCHPAD (NSManagedObjectContext)
    // --------------------------------------------------------------------------
    // 'container.viewContext' is our main study desk.
    // Whenever we create a note, edit a word, or erase something, we do it right here
    // in fast temporary computer memory (RAM) before saving to the permanent disk.
    var context: NSManagedObjectContext {
        return container.viewContext
    }

    // --------------------------------------------------------------------------
    // 🚪 4. OPENING THE CABINET (Initializer / init)
    // --------------------------------------------------------------------------
    // This initializer runs automatically when 'CoreDataStorageService.shared' is first created.
    // Parameter 'inMemory': If true, data is stored in temporary RAM (great for tests & previews!).
    init(inMemory: Bool = false) {
        // Step A: Point to our database model file named "NoteModel"
        container = NSPersistentContainer(name: "NoteModel")
        
        // Step B: If inMemory is true, redirect the file destination to "/dev/null" (nowhere on disk)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Step C: Open up the database stores on the physical device disk
        container.loadPersistentStores { description, error in
            // Step D: Use 'if let' to check if an error occurred while unlocking the cabinet
            if let error = error {
                print("Uh-oh! Could not open filing cabinet: \(error.localizedDescription)")
            } else {
                print("Yay! Core Data filing cabinet is open and ready to use!")
            }
        }
    }

    // --------------------------------------------------------------------------
    // 🔒 5. LOCKING CHANGES TO PERMANENT DISK (saveContext function)
    // --------------------------------------------------------------------------
    // When you finish drawing or writing notes on your desk, calling this function
    // writes all the changes permanently into the phone's flash storage!
    func saveContext() {
        // Step A: Check if we actually made any changes (saves battery and processing power!)
        if context.hasChanges {
            // Step B: Use do-try-catch to perform the save safely
            do {
                try context.save()
                print("Success! Your notes were saved permanently to the device!")
            } catch {
                // If something went wrong, print the error so we can fix it!
                print("Oops! Could not save notes: \(error.localizedDescription)")
            }
        }
    }
}
