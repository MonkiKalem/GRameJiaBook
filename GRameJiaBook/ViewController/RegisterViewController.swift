import UIKit
import CoreData

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var isAdminTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        // Validate input
        guard let email = emailTextField.text, !email.isEmpty,
              let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Please fill all fields.")
            return
        }
        
        // Email validation (must be in correct email format)
        if !isValidEmail(email) {
            showAlert(message: "Please enter a valid email address.")
            return
        }
        
        // Username validation (must be at least 6 characters)
        if username.count < 6 {
            showAlert(message: "Username must be at least 6 characters.")
            return
        }
        
        // Password validation (must contain both numbers and letters)
        if !isValidPassword(password) {
            showAlert(message: "Password must contain at least one letter and one number.")
            return
        }
        
        // Confirm password validation
        if password != confirmPassword {
            showAlert(message: "Passwords do not match.")
            return
        }
        
        // Determine if the user should be an admin
        let isAdmin = isAdminTextField.text == "130504"
        
        // Save user to Core Data
        saveUserToCoreData(email: email, username: username, password: password, isAdmin: isAdmin)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "(?=.*[A-Za-z])(?=.*\\d).{6,}"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }
    
    func saveUserToCoreData(email: String, username: String, password: String, isAdmin: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Create a new User entity
        let userEntity = NSEntityDescription.entity(forEntityName: "User", in: context)!
        let user = NSManagedObject(entity: userEntity, insertInto: context)
        
        // Set attributes
        user.setValue(UUID(), forKey: "id")
        user.setValue(email, forKey: "email")
        user.setValue(username, forKey: "username")
        user.setValue(password, forKey: "password")
        user.setValue(isAdmin, forKey: "isAdmin")
        user.setValue(0.0, forKey: "balance")  // Default balance to 0
        
        do {
            // Save to Core Data
            try context.save()
            // Show success message
            showAlert(message: "Registration successful!")
            
            // Debug: Fetch all users and print their info
            fetchUsersFromCoreData()
        } catch {
            // Handle error
            showAlert(message: "Failed to save user.")
        }
    }
    
    func fetchUsersFromCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        
        do {
            let users = try context.fetch(fetchRequest)
            for user in users {
                if let email = user.value(forKey: "email") as? String,
                   let username = user.value(forKey: "username") as? String,
                   let isAdmin = user.value(forKey: "isAdmin") as? Bool {
                    print("User: \(username), Email: \(email), isAdmin: \(isAdmin)")
                }
            }
        } catch {
            print("Failed to fetch users: \(error)")
        }
    }
    
    // Function to display an alert
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginGoToButton(_ sender: UIButton) {
        let LoginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(LoginVC, animated: true)
    }
}
