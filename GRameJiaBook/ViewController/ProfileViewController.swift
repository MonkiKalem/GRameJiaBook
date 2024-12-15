import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var controlModeUI: UISegmentedControl!
    @IBOutlet weak var logoutButton: UIButton!
    
    // Logout action
    @IBAction func logoutButtonOnTapped(_ sender: Any) {
        print("logout button is pressed")
        logoutUser()
    }

    // Change theme
    @IBAction func controlModeChanged(_ sender: UISegmentedControl) {
        let selectedSegmentIndex = controlModeUI.selectedSegmentIndex
        
        switch selectedSegmentIndex {
        case 0:
            UserDefaults.standard.setValue("light", forKey: "theme")
        case 1:
            UserDefaults.standard.setValue("dark", forKey: "theme")
        case 2:
            UserDefaults.standard.removeObject(forKey: "theme")
        default:
            print("Invalid Index")
        }

        // Post a notification to re-apply the theme globally
        NotificationCenter.default.post(name: NSNotification.Name("ThemeChanged"), object: nil)
    }

    func loadTheme() {
        let savedTheme = UserDefaults.standard.string(forKey: "theme")
        
        switch savedTheme {
        case "light":
            overrideUserInterfaceStyle = .light
            controlModeUI.selectedSegmentIndex = 0
        case "dark":
            overrideUserInterfaceStyle = .dark
            controlModeUI.selectedSegmentIndex = 1
        default:
            overrideUserInterfaceStyle = .unspecified
            controlModeUI.selectedSegmentIndex = 2
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTheme() // Load the current theme

        // Load user information from UserDefaults
        if let username = UserDefaults.standard.string(forKey: "userName"),
           let email = UserDefaults.standard.string(forKey: "userEmail") {
            usernameLabel.text = username
            emailLabel.text = email
        } else {
            usernameLabel.text = "Guest"
            emailLabel.text = "Not Logged In"
        }
    }

    func logoutUser() {
        // Clear all user-related data from UserDefaults
        UserDefaults.standard.removeObject(forKey: "userID")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userBalance")
        UserDefaults.standard.removeObject(forKey: "isAdmin")
        
        // Optionally clear the theme (optional, depends on app logic)
        // UserDefaults.standard.removeObject(forKey: "theme")
        
        UserDefaults.standard.synchronize()
        
        print("User has been logged out successfully.")
        
        // Navigate back to the LoginViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController {
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        } else {
            print("Error: LoginViewController not found.")
        }
    }
}
