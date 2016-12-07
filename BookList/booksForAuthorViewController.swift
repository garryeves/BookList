//
//  booksForAuthorViewController.swift
//  BookList
//
//  Created by Garry Eves on 1/12/16.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import UIKit
import DLRadioButton

class booksForAuthorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MyPickerDelegate, UITextFieldDelegate
{
    @IBOutlet weak var tblBooks: UITableView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnAuthor: UIButton!
    @IBOutlet weak var btnAscending: DLRadioButton!
    @IBOutlet weak var btnDescending: DLRadioButton!
    
    var googleData: GoogleBooks!
    var authorName: String!
    var delegate: MyMainDelegate!
    
    private var shelfList: ShelvesList!
    private var bookList: [workingBooksForAuthor] = Array()
    private var selectedBook: Int = -1
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        notificationCenter.addObserver(self, selector: #selector(self.googleBooksAuthorFinished), name: googleBooksAuthorLoadFinished, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.changeBookShelf(_:)), name: changeBookShelfFinished, object: nil)

        lblStatus.text = "Getting list of books from Google Books"
        lblStatus.isHidden = false
        tblBooks.isHidden = true
        
        if authorName == nil
        {
            navTitle.title = "Search for book"
            lblStatus.text = "Please enter search terms"
        }
        else
        {
            navTitle.title = authorName
            
            let _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.getBookList), userInfo: nil, repeats: false)
        }
        
        // Populate array of shelves
        
        shelfList = ShelvesList()
        
        setSortOrder()
        
        txtSearch.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        notificationCenter.removeObserver(googleBooksAuthorLoadFinished)
        notificationCenter.removeObserver(changeBookShelfFinished)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "stringPickerSegue"
        {
            let stringPicker = segue.destination as! StringPickerViewController
            
            selectedBook = sender as! Int
            
            // Display the picker with the list of available shelves
            
            var displayArray: [String] = Array()
            
            for myItem in shelfList.shelves
            {
                displayArray.append(myItem.shelfName)
            }
            
            stringPicker.displayArray = displayArray
            stringPicker.delegate = self
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return bookList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookEntry") as! bookForAuthorHeader
        
        if bookList[indexPath.row].authorString == ""
        {
            cell.lblName.text = "\(bookList[indexPath.row].bookName)"
        }
        else
        {
            cell.lblName.text = "\(bookList[indexPath.row].bookName) - \(bookList[indexPath.row].authorString)"
        }
        
        cell.lblPublished.text = bookList[indexPath.row].published
        
        if bookList[indexPath.row].newShelf == ""
        {
            if bookList[indexPath.row].currentShelf == ""
            {
                cell.btnShelves.tintColor = UIColor.gray
                cell.btnShelves.setTitle("Select Shelf", for: .normal)
            }
            else
            {
                cell.btnShelves.tintColor = lblStatus.tintColor
                cell.btnShelves.setTitle(bookList[indexPath.row].currentShelf, for: .normal)
            }
        }
        else
        {
            cell.btnShelves.tintColor = UIColor.red
            cell.btnShelves.setTitle(bookList[indexPath.row].newShelf, for: .normal)
        }
        
        if bookList[indexPath.row].imageURL == ""
        {
            cell.imgView.isHidden = true
        }
        else
        {
            cell.imgView.isHidden = false
            
            // check to see if we already have an image for the book
            
            let myImage = myDatabaseConnection.getImage(bookID: bookList[indexPath.row].bookID)
            
            if myImage == nil
            {
                let url = URL(string: bookList[indexPath.row].imageURL)
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                
                let workingImage = UIImage(data: data!)
                
                myDatabaseConnection.saveImage(bookList[indexPath.row].bookID, image: workingImage!)
                cell.imgView.image = workingImage
            }
            else
            {
                cell.imgView.image = myImage
            }
        }

        
        cell.rowNum = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if ((indexPath as NSIndexPath).row % 2 == 0)
        {
            cell.backgroundColor = myRowColour
        }
        else
        {
            cell.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        if delegate != nil
        {
            delegate.reloadTable()
        }
        dismiss(animated: true, completion: nil)
    }
        
    @IBAction func btnSearch(_ sender: UIButton)
    {
        performSearch()
    }
    
    @IBAction func btnSort(_ sender: DLRadioButton)
    {
        if sender == btnAscending
        {
            googleData.sortOrder = sortOrderAscending
        }
        else
        {
            googleData.sortOrder = sortOrderDescending
        }
        
        setSortOrder()
        tblBooks.reloadData()
    }
    
    func setSortOrder()
    {
        if googleData.sortOrder == sortOrderAscending
        {
            btnAscending.isSelected = true
            btnDescending.isSelected = false
        }
        else
        {
            btnAscending.isSelected = false
            btnDescending.isSelected = true
        }
        
        googleData.sortSearchResults()
        
        googleBooksAuthorFinished()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        performSearch()
        
        return true
    }
    
    func performSearch()
    {
        // Check to see if there is a search term
        
        if txtSearch.text == "Search text" || txtSearch.text == ""
        {
            let alert = UIAlertController(title: "No search term", message:
                "Please enter something to search for", preferredStyle: UIAlertControllerStyle.alert)
            
            self.present(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        }
        else
        {
            // Go and search
            lblStatus.text = "Getting list of books from Google Books"
            googleData.searchBooks(searchTerm: txtSearch.text!, startIndex: 0)
        }
    }
    
    func myPickerDidFinish(_ index: Int)
    {
        // Do return logic
        
        // Go and get the book details from the database
        
        
        if bookList[selectedBook].currentShelf == ""
        {
            // Create a new book entry
            
            let myBookEntry = googleData.getBookFromGoogle(bookID: bookList[selectedBook].bookID, shelfName: shelfList.shelves[index].shelfName)
            
            if myBookEntry != nil
            {
                myBookEntry?.addToShelf(shelfID: shelfList.shelves[index].shelfID, googleData: googleData)
                bookList[selectedBook].newShelf = shelfList.shelves[index].shelfName
            }            
        }
        else
        {
            // Get the current shelf
            
            let myBookEntry = Book(bookID: bookList[selectedBook].bookID)

            let tempShelf = Shelf(shelfName: bookList[selectedBook].currentShelf)
            
            myBookEntry.moveBetweenShelves(fromShelfID: tempShelf.shelfID, toShelfID: shelfList.shelves[index].shelfID, googleData: googleData)
            
            bookList[selectedBook].newShelf = shelfList.shelves[index].shelfName
        }
               
        tblBooks.reloadData()
    }
    
    func getBookList()
    {
        googleData.getBooksForAuthor(authorName: authorName, startIndex: 0)
    }
    
    func googleBooksAuthorFinished()
    {
        bookList = googleData.authorBooks
        
        if bookList.count > 0
        {
            lblStatus.isHidden = true
            tblBooks.isHidden = false
            tblBooks.reloadData()
        }
        else
        {
            lblStatus.text = "No Books found"
            lblStatus.isHidden = false
            tblBooks.isHidden = true
        }
    }
    
    func changeBookShelf(_ notification: Notification)
    {
        let row = (notification as NSNotification).userInfo!["row"] as! Int
        
        performSegue(withIdentifier: "stringPickerSegue", sender: row)
    }
}

class bookForAuthorHeader: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPublished: UILabel!
    @IBOutlet weak var btnShelves: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    
    var rowNum: Int!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnShelves(_ sender: UIButton)
    {
        let selectedDictionary = ["row" : rowNum!]
        notificationCenter.post(name: changeBookShelfFinished, object: nil, userInfo:selectedDictionary)
    }
}

    
