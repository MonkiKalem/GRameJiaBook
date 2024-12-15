import UIKit
import CoreData

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerGoToPageButton: UIButton!
    
    // Function to navigate to Admin Dashboard
    func navigateToAdminDashboard() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let adminVC = storyboard.instantiateViewController(withIdentifier: "AdminDashboardViewController") as? AdminDashboardViewController {
            print("Navigating to Admin Dashboard")  // Log successful navigation
            self.navigationController?.pushViewController(adminVC, animated: true)
        } else {
            print("Error: Admin Dashboard ViewController not found")  // Log error
        }
    }

    // Function to navigate to User Dashboard
    func navigateToUserDashboard() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let userVC = storyboard.instantiateViewController(withIdentifier: "UserDashboardViewController") as? UserDashboardViewController {
            print("Navigating to User Dashboard")  // Log successful navigation
            self.navigationController?.pushViewController(userVC, animated: true)
        } else {
            print("Error: User Dashboard ViewController not found")  // Log error
        }
    }

    // Function to authenticate user and navigate based on their role
    func authenticateUser(email: String, password: String) {
        print("Attempting to authenticate user with email: \(email)")  // Log authentication attempt
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        // Fetch the user based on email and password
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "email == %@ AND password == %@", email, password)

        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                print("User found: \(user)")  // Log user details

                // Retrieve the user's details including UUID, balance, username, and admin status
                let userID = user.value(forKey: "id") as? UUID
                let username = user.value(forKey: "username") as? String
                let balance = user.value(forKey: "balance") as? Double ?? 0.0
                let isAdmin = user.value(forKey: "isAdmin") as? Bool ?? false

                // Print the user details to the console
                print("User Details:")
                print("UUID: \(userID?.uuidString ?? "N/A")")
                print("Username: \(username ?? "N/A")")
                print("Balance: \(balance)")
                print("Is Admin: \(isAdmin)")

                // Save user details to UserDefaults
                if let userID = userID {
                    UserDefaults.standard.set(userID.uuidString, forKey: "userID")
                }
                UserDefaults.standard.set(email, forKey: "userEmail")
                UserDefaults.standard.set(username, forKey: "userName")
                UserDefaults.standard.set(balance, forKey: "userBalance")
                UserDefaults.standard.set(isAdmin, forKey: "isAdmin")

                // Navigate based on user role
                if isAdmin {
                    print("User is an admin, navigating to Admin Dashboard")  // Log admin navigation
                    navigateToAdminDashboard()
                } else {
                    print("User is a regular user, navigating to User Dashboard")  // Log regular user navigation
                    navigateToUserDashboard()
                }
            } else {
                print("Error: Invalid email or password.")  // Log invalid login attempt
                showAlert(message: "Invalid email or password.")
            }
        } catch {
            print("Error: Failed to fetch user data. \(error.localizedDescription)")  // Log fetch error
            showAlert(message: "Failed to fetch user data.")
        }
    }

    // Function to display an alert
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // Function to handle login button tap
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Error: Please enter both email and password.")  // Log missing fields
            showAlert(message: "Please enter both email and password.")
            return
        }
        
        // Perform login logic
        authenticateUser(email: email, password: password)
    }
    
    // Function to navigate to the register view
    @IBAction func registerGoToPageButtonTapped(_ sender: Any) {
        let RegisterVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
            self.navigationController?.pushViewController(RegisterVC, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
    }
}
