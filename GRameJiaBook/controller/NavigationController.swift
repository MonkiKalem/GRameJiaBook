//
//  NavigationController.swift
//  GRameJiaBook
//
//  Created by Yassar Annabil on 15/12/24.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        checkLoginStatus()
    }
    
    func checkLoginStatus() {
        // Check if a user ID exists in UserDefaults
        if UserDefaults.standard.string(forKey: "userID") == nil {
            print("No user is logged in. Redirecting to LoginViewController.")
            
            // Navigate to LoginViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true, completion: nil)
            } else {
                print("Error: LoginViewController not found.")
            }
        } else {
            print("User is logged in. Proceeding to home")
            
            // Fetch the user's role from UserDefaults
            if let userRole = UserDefaults.standard.string(forKey: "isAdmin") {
                print("UserDefaults 'isAdmin' value: \(userRole)") // Debug log
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                if userRole == "1" {
                    // If the role is "admin", navigate to AdminDashboard
                    if let adminDashboardVC = storyboard.instantiateViewController(withIdentifier: "AdminDashboardViewController") as? UIViewController {
                        print("Navigating to Admin Dashboard")
                        self.pushViewController(adminDashboardVC, animated: true)
                    } else {
                        print("Error: AdminDashboardViewController not found.")
                    }
                } else {
                    // If the role is not "admin", navigate to UserDashboard
                    if let userDashboardVC = storyboard.instantiateViewController(withIdentifier: "UserDashboardViewController") as? UIViewController {
                        print("Navigating to User Dashboard")
                        self.pushViewController(userDashboardVC, animated: true)
                    } else {
                        print("Error: UserDashboardViewController not found.")
                    }
                }
            } else {
                print("Error: User role not found in UserDefaults.")
            }
        }
    }
}
