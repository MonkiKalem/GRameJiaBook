import UIKit
import CoreData

class TopUpViewController: UIViewController {
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var topUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the view
        loadUserBalance()
    }

    // Fetch and display the current user's balance
    func loadUserBalance() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
            let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
            userFetchRequest.predicate = NSPredicate(format: "email == %@", userEmail)

            do {
                let users = try context.fetch(userFetchRequest)
                if let user = users.first {
                    balanceLabel.text = String(format: "Balance: %.2f", user.balance)
                }
            } catch {
                print("Failed to fetch user balance: \(error)")
            }
        }
    }

    // Handle the top-up action
    @IBAction func topUpButtonTapped(_ sender: UIButton) {
        guard let topUpAmountText = amountTextField.text,
              let topUpAmount = Double(topUpAmountText), topUpAmount > 0 else {
            // Show an alert for invalid input
            let alert = UIAlertController(title: "Invalid Amount", message: "Please enter a valid top-up amount.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
            let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
            userFetchRequest.predicate = NSPredicate(format: "email == %@", userEmail)

            do {
                let users = try context.fetch(userFetchRequest)
                if let user = users.first {
                    // Update the user's balance
                    user.balance += topUpAmount
                    try context.save()

                    // Refresh the balance label
                    loadUserBalance()

                    // Clear the text field
                    amountTextField.text = ""

                    // Show a success message
                    let successAlert = UIAlertController(title: "Success", message: "Your balance has been updated.", preferredStyle: .alert)
                    successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        // Pop the view controller after success
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(successAlert, animated: true, completion: nil)
                }
            } catch {
                print("Failed to update user balance: \(error)")
            }
        }
    }
}
