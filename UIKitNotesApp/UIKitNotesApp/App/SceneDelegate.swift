import UIKit

// ==============================================================================
// 🪟 ARCHITECTURAL LAYER: [APP WINDOW & SCENE BUILDER]
// 📄 FILE: SceneDelegate.swift (for UIKit)
// ==============================================================================
//
// 🧸 STORY TIME: THE STAGE CARPENTER & WINDOW MAKER 🪟🪵
// ------------------------------------------------------------------------------
// Imagine you are putting on a big puppet show.
// Before the puppets can act or dance, the stage carpenter needs to build the physical stage,
// place the big wooden frame (UIWindow), and hang the main curtains!
//
// In UIKit, 'SceneDelegate' is our Stage Carpenter!
// It takes the empty phone screen (UIWindowScene), creates a shiny glass window (UIWindow),
// puts our NoteListViewController inside a sliding UINavigationController,
// and turns on the spotlights with 'window.makeKeyAndVisible()' so you can see it!
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
// 6. 'UINavigationController' -> The "Slide Projector" 🎞️: Provides the top navigation bar
//                                and manages sliding transitions between screens.
// 7. 'rootViewController'     -> The very first primary screen mounted onto the glass window.
// 8. 'makeKeyAndVisible()'    -> "Turn On The Lights!" 💡: Makes the window active and visible!
// ==============================================================================

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // --------------------------------------------------------------------------
    // 🪟 1. THE GLASS WINDOW CONTAINER
    // --------------------------------------------------------------------------
    // Holds the UI hierarchy displayed on the phone's physical screen.
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
        // Step A: The Bouncer check - Make sure this scene is a valid UIWindowScene
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Step B: Create a brand new glass window using the window scene coordinate space
        let window = UIWindow(windowScene: windowScene)
        
        // Step C: Create our main notes list screen controller
        let rootViewController = NoteListViewController()
        
        // Step D: Wrap it inside a UINavigationController so it has a top bar and navigation stack
        let navigationController = UINavigationController(rootViewController: rootViewController)

        // Step E: Set the navigation controller as the root of our window
        window.rootViewController = navigationController
        
        // Step F: Save our constructed window to the class property
        self.window = window
        
        // Step G: Turn on the lights and display the window in front of the child!
        window.makeKeyAndVisible()
    }
}
