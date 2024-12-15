import UIKit
import CoreData

class UserDashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bookTableView: UITableView!
    @IBOutlet weak var cartGotoButton: UIImageView!
    @IBOutlet weak var transactionGotoButton: UIImageView!
    @IBOutlet weak var profileGotoButton: UIImageView!
    
    var books: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        print("User Dashboard Loaded")
        
        // Set up the table view
        bookTableView.dataSource = self
        bookTableView.delegate = self

        // Fetch user info and books from Core Data
        fetchUserInfo()
        fetchBooks()
        
        // Set up tap gestures
        setupTapGestures()
    }
    
    
    @IBAction func topUpButton(_ sender: Any) {
        performSegue(withIdentifier: "showTopUp", sender: self)
    }
    
    // Set up the tap gestures for the buttons
    func setupTapGestures() {
        // Tap gesture for the Cart button
        let cartTapGesture = UITapGestureRecognizer(target: self, action: #selector(cartGotoTapped))
        cartGotoButton.isUserInteractionEnabled = true
        cartGotoButton.addGestureRecognizer(cartTapGesture)
        
        // Tap gesture for the Transaction button
        let transactionTapGesture = UITapGestureRecognizer(target: self, action: #selector(transactionGotoTapped))
        transactionGotoButton.isUserInteractionEnabled = true
        transactionGotoButton.addGestureRecognizer(transactionTapGesture)
        
        // Tap gesture for the Profile button
        let profileTapGesture = UITapGestureRecognizer(target: self, action: #selector(profileGotoTapped))
        profileGotoButton.isUserInteractionEnabled = true
        profileGotoButton.addGestureRecognizer(profileTapGesture)
    }

    // Fetch the current logged-in user's information (balance and name)
    func fetchUserInfo() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "User")
        if let email = UserDefaults.standard.string(forKey: "userEmail") {
            fetchRequest.predicate = NSPredicate(format: "email == %@", email)
            
            do {
                let users = try context.fetch(fetchRequest)
                if let user = users.first {
                    let balance = user.value(forKey: "balance") as? Double ?? 0.0
                    let username = user.value(forKey: "username") as? String ?? "Unknown"
                    balanceLabel.text = "$\(balance)"
                    nameLabel.text = "Welcome, \(username)"
                }
            } catch {
                print("Failed to fetch user data: \(error)")
            }
        }
    }

    // Fetch available books from Core Data
    func fetchBooks() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Book")
        
        do {
            books = try context.fetch(fetchRequest)
            bookTableView.reloadData()
        } catch {
            print("Failed to fetch books: \(error)")
        }
    }
    
    // TableView DataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath)
        let book = books[indexPath.row]
        
        let title = book.value(forKey: "title") as? String ?? "Unknown Title"
        let price = book.value(forKey: "price") as? Double ?? 0.0
        
        // Set the title and price in the cell
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = "$\(price)"
        
        
        return cell
    }

    // Navigate to the cart view when the cart button is tapped
    @objc func cartGotoTapped() {
        performSegue(withIdentifier: "showCart", sender: self)
    }
    
    // Navigate to the transaction view when the transaction button is tapped
    @objc func transactionGotoTapped() {
        performSegue(withIdentifier: "showTransaction", sender: self)
    }

    // Navigate to the profile view when the profile button is tapped
    @objc func profileGotoTapped() {
        performSegue(withIdentifier: "showProfile", sender: self)
    }

    // TableView didSelectRow method for book selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBook = books[indexPath.row]
        performSegue(withIdentifier: "showBookDetail", sender: selectedBook)
    }

    // Prepare for the segue to pass selected book data to DetailViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBookDetail" {
            if let detailVC = segue.destination as? DetailViewController,
               let book = sender as? NSManagedObject { // Ensure sender is NSManagedObject
                detailVC.book = book
            } else {
                print("Error: Sender is not an NSManagedObject")
            }
        }
    }
}
