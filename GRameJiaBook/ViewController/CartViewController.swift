import UIKit
import CoreData

class CartViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var checkoutButton: UIButton!
    
    var cartItems: [CartItem] = [] // Stores the cart items for the logged-in user
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchCartItems()
    }
    
    func fetchCartItems() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        // Get the logged-in user's email from UserDefaults
        if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
            let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
            userFetchRequest.predicate = NSPredicate(format: "email == %@", userEmail)
            
            do {
                let users = try context.fetch(userFetchRequest)
                if let user = users.first {
                    // Access the user's cart items via the relationship
                    if let userCartItems = user.cart as? Set<CartItem> {
                        // Filter cart items to exclude books with zero stock
                        cartItems = userCartItems.filter { cartItem in
                            if let book = cartItem.book {
                                if book.stock == 0 {
                                    print("Book \(book.title ?? "Unknown") is out of stock and will not be added to the cart.")
                                    return false
                                }
                                return true
                            }
                            return false // Exclude cart items with no associated book
                        }
                    } else {
                        cartItems = []
                    }
                    // Log the filtered cart items for debugging
                    print("Filtered Cart Items:")
                    for cartItem in cartItems {
                        if let book = cartItem.book {
                            print("Book Title: \(book.title ?? "Unknown"), Quantity: \(cartItem.quantity), Price: \(book.price), Stock: \(book.stock)")
                        }
                    }
                    tableView.reloadData()
                    updateTotalAmount()
                }
            } catch {
                print("Failed to fetch user or cart items: \(error)")
            }
        }
    }
    
    func updateTotalAmount() {
        let totalAmount = cartItems.reduce(0.0) { total, cartItem in
            guard let book = cartItem.book else { return total }
            let price = Double(book.price) ?? 0.0
            return total + (price * Double(cartItem.quantity))
        }
        totalAmountLabel.text = String(format: "Total: %.2f", totalAmount)
    }
    
    @IBAction func checkoutButtonTapped(_ sender: UIButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        for cartItem in cartItems {
            if let book = cartItem.book, cartItem.quantity > book.stock {
                let alert = UIAlertController(
                    title: "Error",
                    message: "Insufficient stock for \(book.title ?? "Unknown").",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        // Calculate the total amount inline
        let totalAmount = cartItems.reduce(0.0) { total, cartItem in
            guard let book = cartItem.book else { return total }
            let price = Double(book.price) ?? 0.0
            return total + (price * Double(cartItem.quantity))
        }
        
        // Fetch the user's balance
        if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
            let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
            userFetchRequest.predicate = NSPredicate(format: "email == %@", userEmail)
            
            do {
                let users = try context.fetch(userFetchRequest)
                if let user = users.first {
                    // Ensure the user has sufficient balance
                    if user.balance < totalAmount {
                        print("Insufficient balance. Cannot proceed with checkout.")
                        let alert = UIAlertController(title: "Error", message: "Your balance is insufficient to complete the checkout.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    // Deduct the total amount from the user's balance
                    user.balance -= totalAmount
                }
            } catch {
                print("Failed to fetch user for balance check: \(error)")
                return
            }
        }
        
        // Create a new transaction
        let transaction = Transaction(context: context)
        transaction.id = UUID()
        transaction.date = Date()
        transaction.totalAmount = totalAmount
        
        // Link transaction to the user
        if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
            let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
            userFetchRequest.predicate = NSPredicate(format: "email == %@", userEmail)
            do {
                let users = try context.fetch(userFetchRequest)
                if let user = users.first {
                    transaction.user = user
                    user.addToTransaction(transaction)  // Maintain bidirectional relationship
                }
            } catch {
                print("Failed to fetch user for transaction: \(error)")
            }
        }
        
        // Link cart items to the transaction and update book stock
        for cartItem in cartItems {
            cartItem.transaction = transaction // This is the key step
            
            if let book = cartItem.book {
                // Decrease book stock
                book.stock -= Int16(cartItem.quantity)
                if book.stock < 0 {
                    book.stock = 0 // Ensure stock doesn't go negative
                }
                print("Updated Book Stock: \(book.title ?? "Unknown") | Remaining Stock: \(book.stock)")
            } else {
                print("CartItem without Book reference")
            }
        }
        
        // Save transaction and clear the cart
        do {
            try context.save()
            print("Transaction successfully saved.")
            
            // Clear cart in Core Data
            for cartItem in cartItems {
                cartItem.user = nil // Remove relationship with the cart
            }
            
            // Clear cart in memory (UI)
            cartItems.removeAll()
            tableView.reloadData()
            updateTotalAmount()
            
            let alert = UIAlertController(title: "Success", message: "Checkout completed successfully.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } catch {
            print("Failed to save transaction or clear cart: \(error)")
        }
    }
}
extension CartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartItemCell", for: indexPath)

        let cartItem = cartItems[indexPath.row]
        if let book = cartItem.book {
            cell.textLabel?.text = book.title
            cell.detailTextLabel?.text = "Price: \(book.price) | Quantity: \(cartItem.quantity)"
        }

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cartItemToDelete = cartItems[indexPath.row]

            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext

            context.delete(cartItemToDelete)

            do {
                try context.save()
                cartItems.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                updateTotalAmount()
            } catch {
                print("Failed to delete cart item: \(error)")
            }
        }
    }
}
