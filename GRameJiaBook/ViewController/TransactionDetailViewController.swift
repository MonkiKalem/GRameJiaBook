import UIKit

class TransactionDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var transaction: Transaction? // Transaction passed from the previous view controller
    var cartItems: [CartItem] = [] // Array to store CartItems for the Transaction
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView! // TableView for books and their quantities

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup table view delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set the transaction details to the labels
        if let transaction = transaction {
            dateLabel.text = "Date: \(formatDate(transaction.date ?? Date()))"
            totalAmountLabel.text = String(format: "Total: $%.2f", transaction.totalAmount)
            
            // Get all cart items linked to this transaction
            if let cartItemsFromTransaction = transaction.cart?.allObjects as? [CartItem] {
                self.cartItems = cartItemsFromTransaction
            }
        }
        
        // Reload the table to display cart items
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath)
        let cartItem = cartItems[indexPath.row]
        
        if let book = cartItem.book {
            cell.textLabel?.text = book.title
            cell.detailTextLabel?.text = "Quantity: \(cartItem.quantity) | Price: $\(String(format: "%.2f", book.price))"
        } else {
            cell.textLabel?.text = "Unknown Book"
            cell.detailTextLabel?.text = "No details available"
        }
        
        return cell
    }

    // MARK: - UITableViewDelegate (optional)
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cartItem = cartItems[indexPath.row]
        if let book = cartItem.book {
            print("Selected book: \(book.title ?? "Unknown")")
        }
    }

    // MARK: - Helper Functions
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
