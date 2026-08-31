import UIKit

// ==============================================================================
// 🪟 ARCHITECTURAL LAYER: [APP WINDOW & SCENE BUILDER]
// 📄 FILE: SceneDelegate.swift (for Storyboard UIKit)
// ==============================================================================
//
// 🧸 STORY TIME: THE STAGE CARPENTER WHO FOLLOWS THE BLUEPRINT! 🪟🪵
// ------------------------------------------------------------------------------
// Imagine you are putting on a big puppet show.
// In Programmatic UIKit, the carpenter had to measure and saw every piece of wood manually.
//
// But in Storyboard UIKit, the carpenter has a magical pre-assembled set piece
// from 'Main.storyboard'!
//
// When iOS connects a new scene:
//   1. iOS creates the glass UIWindow automatically.
//   2. iOS instantiates the initial UINavigationController from Main.storyboard.
//   3. iOS assigns it as 'window.rootViewController'.
//   4. All our '@IBOutlet' and '@IBAction' wires are automatically connected!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'UIResponder'            -> Apple's base object that understands touches and taps.
// 2. 'UIWindowSceneDelegate'  -> A rulebook of duties for managing a window on the screen.
// 3. 'var window: UIWindow?'  -> The physical glass window that holds all visual views.
// 4. 'guard let ... else'     -> The "Bouncer at the Door" 🚪: Checks if something exists;
//                                if not, it exits immediately to prevent errors!
// 5. 'as?' (Type Cast)        -> "Polite Check": Verifies if 'scene' is really a UIWindowScene.
// 6. 'UIScene'                -> An abstract screen surface managed by the operating system.
// ==============================================================================

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // --------------------------------------------------------------------------
    // 🪟 1. THE GLASS WINDOW CONTAINER
    // --------------------------------------------------------------------------
    // In a Storyboard-based app, iOS automatically connects this window property
    // to the initial view controller defined in Main.storyboard.
    var window: UIWindow?

    // --------------------------------------------------------------------------
    // 🪵 2. BUILDING THE STAGE (willConnectTo)
    // --------------------------------------------------------------------------
    // This function runs when iOS connects a new scene to our app.
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // The Bouncer check - Verifies this scene is a valid UIWindowScene.
        // The storyboard handles loading the Initial View Controller automatically!
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}
