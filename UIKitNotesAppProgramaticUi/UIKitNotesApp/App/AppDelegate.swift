import UIKit

// ==============================================================================
// 🚦 ARCHITECTURAL LAYER: [APP LIFECYCLE CONTROLLER]
// 📄 FILE: AppDelegate.swift (for UIKit)
// ==============================================================================
//
// 🧸 STORY TIME: THE AIR TRAFFIC CONTROLLER 🛫🛬
// ------------------------------------------------------------------------------
// Imagine a busy airport with dozens of planes arriving and taking off.
// High up in the control tower sits the Air Traffic Controller.
//
// The Air Traffic Controller doesn't fly the planes or serve orange juice to passengers.
// Instead, their job is to handle the BIG events:
//   - "Plane is starting its engines!" (App is launching)
//   - "Plane is parking at the gate!" (App is closing or going to the background)
//   - "Open a new terminal window for passengers!" (Connecting a UI Scene)
//
// In UIKit, 'AppDelegate' is our app's top-level Air Traffic Controller!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'import'                 -> Opens Apple's big toy box of tools and UI elements.
// 2. 'UIKit'                  -> Apple's classic, powerful framework for building iOS apps.
// 3. '@main'                  -> The gold star sticker: "Hey iPhone! Begin executing code right here!"
// 4. 'class'                  -> A blueprint for an intelligent helper living in memory.
// 5. 'UIResponder'            -> Apple's base object that knows how to listen for finger taps and gestures.
// 6. 'UIApplicationDelegate'  -> A rulebook of duties for managing global app lifecycle events.
// 7. 'func'                   -> A function / recipe of actions.
// 8. '_' (Underscore)         -> Tells Swift: "When calling this function, you don't need to write the argument name!"
// 9. 'launchOptions'          -> A dictionary of clues about WHY the app was opened (e.g. user tapped icon or notification).
// 10.'-> Bool'                -> Returns true/false to tell iOS: "Everything is ready, please proceed!"
// 11.'UISceneSession'         -> Represents one active window session on the device screen.
// 12.'UISceneConfiguration'   -> Instructions on which SceneDelegate will build the window.
// ==============================================================================

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // --------------------------------------------------------------------------
    // 🚀 1. APP FINISHED LAUNCHING (The Ignition Key)
    // --------------------------------------------------------------------------
    // This is the very first function iOS runs when you tap our app icon.
    // It returns 'true' to signal to the iPhone that we started up happily!
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Return true to tell iOS everything is running smoothly!
        return true
    }

    // --------------------------------------------------------------------------
    // 🪟 2. CREATING A NEW SCENE SESSION (The Window Configuration)
    // --------------------------------------------------------------------------
    // When iOS wants to open a new window for our app, it asks us for the configuration.
    // We hand back "Default Configuration" which tells iOS to use SceneDelegate.swift!
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
}
