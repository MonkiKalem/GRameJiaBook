import UIKit
import CoreData

class TransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var transactionTableView: UITableView!

    var transactions: [Transaction] = [] // Store transactions for the logged-in user
    var expandedCells: [Bool] = []  // Keep track of expanded cell states

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Transaction History"
        transactionTableView.dataSource = self
        transactionTableView.delegate = self

        fetchTransactions()
    }

    // Fetch transactions related to the logged-in user
    func fetchTransactions() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        // Fetch transactions for the logged-in user
        if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
            let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
            userFetchRequest.predicate = NSPredicate(format: "email == %@", userEmail)

            do {
                let users = try context.fetch(userFetchRequest)
                if let user = users.first {
                    // Access the user's transactions (it's likely a set, not a single transaction)
                    if let userTransactions = user.transaction?.allObjects as? [Transaction] {
                        // Sort the transactions from newest to oldest
                        transactions = userTransactions.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
                        expandedCells = Array(repeating: false, count: transactions.count)  // Initialize expanded state
                    }
                    transactionTableView.reloadData()
                }
            } catch {
                print("Failed to fetch transactions: \(error)")
            }
        }
    }

    // TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        let transaction = transactions[indexPath.row]
        
        // Get date and total amount from the transaction
        let date = transaction.date ?? Date()
        let totalAmount = transaction.totalAmount
        
        // Display book titles associated with the transaction (from cart)
        if let cartItems = transaction.cart?.allObjects as? [CartItem] {
            let bookTitles = cartItems.compactMap { $0.book?.title }.joined(separator: ", ")
            cell.textLabel?.text = "Total: $\(totalAmount)" // Show the total amount as the title
            cell.detailTextLabel?.text = "Date: \(formatDate(date))" // Show only the date as the subtitle
            
            if expandedCells[indexPath.row] {
                cell.detailTextLabel?.numberOfLines = 0  // Allow multiple lines for expanded state
                cell.detailTextLabel?.text = "Date: \(formatDate(date))\nBooks: \(bookTitles)" // Show books
            } else {
                cell.detailTextLabel?.numberOfLines = 1  // Collapse to 1 line
            }
        } else {
            cell.textLabel?.text = "Total: $\(totalAmount)" // Show the total amount if no books
            cell.detailTextLabel?.text = "Date: \(formatDate(date))" // Show only the date
        }
        
        return cell
    }

    // Format date for display
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // Handle row selection (tap to expand/collapse or navigate to details)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Toggle the expanded state for the tapped row
        expandedCells[indexPath.row].toggle()

        // Reload the selected row to show expanded/collapsed view
        tableView.reloadRows(at: [indexPath], with: .automatic)

        // Pass the selected transaction data to the detail view controller
        let selectedTransaction = transactions[indexPath.row]
        performSegue(withIdentifier: "showTransactionDetail", sender: selectedTransaction)
    }

    // Prepare for segue to TransactionDetailViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTransactionDetail" {
            if let destinationVC = segue.destination as? TransactionDetailViewController,
               let transaction = sender as? Transaction {
                destinationVC.transaction = transaction
            }
        }
    }
}
