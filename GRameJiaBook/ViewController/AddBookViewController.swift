import UIKit

protocol AddBookDelegate: AnyObject {
    func didAddBook()
}

class AddBookViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var publisherTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var stockTextField: UITextField!
    
    weak var delegate: AddBookDelegate?
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        // Validate that none of the fields are empty
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
        
        // Validate that price is a valid number
        guard let price = Double(priceText), price > 0 else {
            let alert = UIAlertController(title: "Error", message: "Price must be a valid number greater than 0.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        
        // Validate that stock is a valid number
        guard let stock = Int16(stockText), stock >= 0 else {
            let alert = UIAlertController(title: "Error", message: "Stock must be a valid number greater than or equal to 0.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let newBook = Book(context: context)
        newBook.id = UUID()
        newBook.title = title
        newBook.publisher = publisher
        newBook.price = price
        newBook.stock = stock
        newBook.author = author
        
        // Debugging logs to check the values before saving
        print("Saving New Book:")
        print("Title: \(newBook.title ?? "No Title")")
        print("Publisher: \(newBook.publisher ?? "No Publisher")")
        print("Author: \(newBook.author ?? "No Author")")
        print("Price: \(newBook.price)")
        print("Stock: \(newBook.stock)")
        
        do {
            try context.save()
            
            // Show success alert after saving
            let alert = UIAlertController(title: "Success", message: "Book added successfully!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.delegate?.didAddBook()
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true)
        } catch {
            print("Failed to save new book: \(error)")
        }
    }
}
