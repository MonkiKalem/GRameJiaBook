import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    
    var book: NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let book = book {
            print("Received object: \(book)")  // Check the type of book
            if let book = book as? NSManagedObject {
                titleLabel.text = book.value(forKey: "title") as? String ?? "Unknown Title"
                authorLabel.text = "Author: \(book.value(forKey: "author") as? String ?? "Unknown Author")"
                publisherLabel.text = "Publisher: \(book.value(forKey: "publisher") as? String ?? "Unknown Publisher")"
                priceLabel.text = "$\(book.value(forKey: "price") as? Double ?? 0.0)"
                
                if let stock = book.value(forKey: "stock") as? Int16 {
                    stockLabel.text = "Stock: \(stock)"
                    
                    // Change text color to red if stock is zero
                    if stock == 0 {
                        stockLabel.textColor = UIColor.red
                    } else {
                        stockLabel.textColor = UIColor.black
                    }
                } else {
                    stockLabel.text = "Stock: Unknown"
                    stockLabel.textColor = UIColor.black
                }
            } else {
                print("Error: Book is not an NSManagedObject")
            }
        }
        
    }

    



    // Function to log all cart items for the current user
    func logCartItems(for user: User, context: NSManagedObjectContext) {
        if let userCartItems = user.cart as? Set<CartItem> {
            print("Current Cart Items:")
            for cartItem in userCartItems {
                if let book = cartItem.book {
                    // Print the full object to see if it's valid
                    print("Book object: \(book)")  // Check if book object is not nil
                    
                    // Safely access book properties
                    let title = book.value(forKey: "title") as? String ?? "Unknown Title"
                    let price = book.value(forKey: "price") as? Double ?? 0.0
                    print("Book Title: \(title), Quantity: \(cartItem.quantity), Price: \(price)")
                } else {
                    print("CartItem with no associated book")
                }
            }
        } else {
            print("No cart items found for this user.")
        }
    }
    
    @IBAction func addToCartTapped(_ sender: Any) {
        guard let book = book, let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("No book object or AppDelegate is unavailable.")
            return
        }
        
        // Get the managed object context from AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Ensure the user ID is set
        guard let userEmail = UserDefaults.standard.string(forKey: "userEmail") else {
            print("User email not found in UserDefaults.")
            return
        }
        
        // Fetch the User entity based on the user email from UserDefaults
        let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
        userFetchRequest.predicate = NSPredicate(format: "email == %@", userEmail)
        
        do {
            let users = try context.fetch(userFetchRequest)
            guard let user = users.first else {
                print("User not found in Core Data.")
                return
            }
            
            // Show alert to input quantity
            let alert = UIAlertController(title: "Add to Cart", message: "Enter quantity:", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.keyboardType = .numberPad
                textField.placeholder = "Enter quantity"
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
                guard let quantityText = alert.textFields?.first?.text, let quantity = Int16(quantityText), quantity > 0 else {
                    self?.showErrorAlert(message: "Invalid quantity. Must be at least 1.")
                    return
                }
                
                // Check if the book has enough stock
                guard let currentStock = book.value(forKey: "stock") as? Int16, currentStock >= quantity else {
                    self?.showErrorAlert(message: "Not enough stock available.")
                    return
                }
                
                // Check if the book already exists in the cart
                if let existingCartItem = user.cart?.first(where: { ($0 as? CartItem)?.book == book }) as? CartItem {
                    // Update the quantity
                    existingCartItem.quantity += quantity
                    print("Updated quantity for existing cart item.")
                } else {
                    // Create a new CartItem
                    let cartItemEntity = NSEntityDescription.entity(forEntityName: "CartItem", in: context)!
                    let cartItem = NSManagedObject(entity: cartItemEntity, insertInto: context)
                    
                    // Set attributes and relationships
                    cartItem.setValue(UUID(), forKey: "id")
                    cartItem.setValue(quantity, forKey: "quantity")
                    cartItem.setValue(book, forKey: "book")
                    cartItem.setValue(user, forKey: "user")
                    
                    // Add the new cart item to the user's cart set
                    let userCart = user.mutableSetValue(forKey: "cart")
                    userCart.add(cartItem)
                    print("Added new cart item.")
                }
                
                // Save the context
                do {
                    try context.save()
                    print("Book added to cart successfully.")
                    self?.logCartItems(for: user, context: context)
                } catch {
                    print("Failed to save cart item: \(error)")
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } catch {
            print("Failed to fetch user or cart items: \(error)")
        }
    }

    // Helper function to show error alerts
    func showErrorAlert(message: String) {
        let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(errorAlert, animated: true, completion: nil)
    }

}
