import UIKit

protocol EditBookDelegate: AnyObject {
    func didEditBook()
}

class EditBookViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var publisherTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var stockTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    
    var book: Book? // The selected book to edit
    weak var delegate: EditBookDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let book = book {
            titleTextField.text = book.title
            publisherTextField.text = book.publisher
            priceTextField.text = "\(book.price)"
            stockTextField.text = "\(book.stock)"
            authorTextField.text = book.author
        } else {
            print("Error: No book passed to EditBookViewController")
        }
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        // Check if any of the required fields are empty
        guard let title = titleTextField.text, !title.isEmpty,
              let publisher = publisherTextField.text, !publisher.isEmpty,
              let author = authorTextField.text, !author.isEmpty,
              let priceText = priceTextField.text, !priceText.isEmpty,
              let stockText = stockTextField.text, !stockText.isEmpty else {
            
            // Show an alert if any required field is empty
            let alert = UIAlertController(title: "Error", message: "All fields must be filled in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        
        // Validate that price and stock are numbers
        guard let price = Double(priceText), price > 0 else {
            let alert = UIAlertController(title: "Error", message: "Price must be a valid number greater than 0.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        
        guard let stock = Int16(stockText), stock >= 0 else {
            let alert = UIAlertController(title: "Error", message: "Stock must be a valid number greater than or equal to 0.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        if let book = book {
            // Debugging logs
            print("Saving Book:")
            print("Title: \(title)")
            print("Publisher: \(publisher)")
            print("Author: \(author)")
            print("Price: \(price)")
            print("Stock: \(stock)")

            book.title = title
            book.publisher = publisher
            book.author = author
            book.price = price
            book.stock = stock
            
            do {
                try context.save()
                
                // Successfully edited, show success alert
                let alert = UIAlertController(title: "Success", message: "Book updated successfully!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.delegate?.didEditBook()
                    self.navigationController?.popViewController(animated: true)
                }))
                present(alert, animated: true)
            } catch {
                print("Failed to update book: \(error)")
            }
        }
    }
}
