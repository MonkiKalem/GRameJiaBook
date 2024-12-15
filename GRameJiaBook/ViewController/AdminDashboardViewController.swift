import UIKit
import CoreData

class AdminDashboardViewController: UIViewController {
    @IBOutlet weak var bookTableView: UITableView!
    @IBOutlet weak var addBookButton: UIButton!
    @IBOutlet weak var profileGoToButton: UIButton!

    @IBOutlet weak var nameLabel: UILabel!
    
    var books: [Book] = [] // Stores the list of books

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let username = UserDefaults.standard.string(forKey: "userName"),
           let email = UserDefaults.standard.string(forKey: "userEmail") {
            nameLabel.text = "Welcome,  \(username)"
        }
        
        self.navigationItem.setHidesBackButton(true, animated: true)

        print("Admin Dashboard Loaded")

        bookTableView.delegate = self
        bookTableView.dataSource = self
        fetchBooks()
    }
    

    func fetchBooks() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()

        do {
            books = try context.fetch(fetchRequest)
            bookTableView.reloadData()
        } catch {
            print("Failed to fetch books: \(error)")
        }
    }

    @IBAction func addBookButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addBookVC = storyboard.instantiateViewController(withIdentifier: "AddBookViewController") as? AddBookViewController {
            addBookVC.delegate = self
            self.navigationController?.pushViewController(addBookVC, animated: true)
        }
    }

    // Function for profileGoToButton
    @IBAction func profileGoToButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showProfile", sender: self)
    }
}

extension AdminDashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath)
        let book = books[indexPath.row]
        cell.textLabel?.text = book.title
        cell.detailTextLabel?.text = "Publisher: \(book.publisher ?? "Unknown"), Stock: \(book.stock)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBook = books[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editBookVC = storyboard.instantiateViewController(withIdentifier: "EditBookViewController") as? EditBookViewController {
            editBookVC.book = selectedBook
            editBookVC.delegate = self
            self.navigationController?.pushViewController(editBookVC, animated: true)
        }
    }

    // Enable swipe-to-delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the book from Core Data
            let bookToDelete = books[indexPath.row]
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            context.delete(bookToDelete)

            do {
                try context.save() // Save the changes to Core Data
                books.remove(at: indexPath.row) // Remove the book from the array
                tableView.deleteRows(at: [indexPath], with: .automatic) // Update the table view
            } catch {
                print("Failed to delete book: \(error)")
            }
        }
    }
}

extension AdminDashboardViewController: AddBookDelegate, EditBookDelegate {
    func didAddBook() {
        fetchBooks()
    }

    func didEditBook() {
        fetchBooks()
    }
}
