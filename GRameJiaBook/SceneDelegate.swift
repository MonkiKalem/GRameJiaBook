import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "NavigationController")
        
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
        
        applyTheme() // Apply the global theme
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Listen for theme change notifications once the app is active
        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: NSNotification.Name("ThemeChanged"), object: nil)
        applyTheme() // Re-apply the theme when the app becomes active
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ThemeChanged"), object: nil)
    }

    @objc func applyTheme() {
        let savedTheme = UserDefaults.standard.string(forKey: "theme")
        switch savedTheme {
        case "light":
            window?.overrideUserInterfaceStyle = .light
        case "dark":
            window?.overrideUserInterfaceStyle = .dark
        default:
            window?.overrideUserInterfaceStyle = .unspecified
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
}
