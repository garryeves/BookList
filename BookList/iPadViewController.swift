//
//  iPadViewController.swift
//  BookList
//
//  Created by Garry Eves on 20/11/16.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import UIKit
import DLRadioButton

protocol MyMainDelegate
{
    func reloadTable()
}

class iPadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MyPickerDelegate, MyMainDelegate, UITextFieldDelegate
{
    @IBOutlet weak var tableBooks: UITableView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnAscending: DLRadioButton!
    @IBOutlet weak var btnDescending: DLRadioButton!
    @IBOutlet weak var btnByShelf: DLRadioButton!
    @IBOutlet weak var btnByAuthor: DLRadioButton!
    @IBOutlet weak var btnByTitle: DLRadioButton!
    @IBOutlet weak var btnEditOrder: UIButton!
    
    var googleData: GoogleBooks!

    private var myBooks: booksToDisplay!
    
    private var myShelvesArray: [Shelf]!
    private var row: Int = 0
    private var selectedBookEntry: Book!
    private var shelfList: ShelvesList!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        myBooks = booksToDisplay()
        
        notificationCenter.addObserver(self, selector: #selector(self.googleDataBooksLoaded), name: goodReadsBookLoadFinished, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.reloadTable), name: reloadTableValues, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.updateState(_:)), name: sectionStateChanged, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.changeBookShelf(_:)), name: changeMainBookShelfFinished, object: nil)

        // LoadShelf details into array
        
        myShelvesArray = Array()
        
        loadShelves()
        
        googleDataBooksLoaded()
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain()
        {
            // Go and get the list of shelves from googleData, and then make sure we have populated them into the data table

            googleData.getBooks()
        }
        else
        {
            print("Not authenticated")
        }
        
        let nib = UINib(nibName: "bookListSectionHeader", bundle: nil)
        tableBooks.register(nib, forHeaderFooterViewReuseIdentifier: "bookListSectionHeader")
        
        shelfList = ShelvesList()
        
        txtSearch.delegate = self
        
        btnAscending.setTitle("Ascending", for: .normal)
        btnAscending.setTitleColor(UIColor.black, for: .normal)
        btnDescending.setTitle("Descending", for: .normal)
        btnDescending.setTitleColor(UIColor.black, for: .normal)
        btnByShelf.setTitle("Shelf", for: .normal)
        btnByShelf.setTitleColor(UIColor.black, for: .normal)
        btnByAuthor.setTitle("Author", for: .normal)
        btnByAuthor.setTitleColor(UIColor.black, for: .normal)
        btnByTitle.setTitle("Title", for: .normal)
        btnByTitle.setTitleColor(UIColor.black, for: .normal)
        
        setGrouping()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier!
        {
            case "bookDetailSegue" :
                let bookDetailView = segue.destination as! bookDetailsViewController
                
                let workingSender = sender as! IndexPath
                
                bookDetailView.googleData = googleData
                bookDetailView.myBooks = myBooks
                
                bookDetailView.section = workingSender.section
                bookDetailView.row = workingSender.row
                bookDetailView.delegate = self
                
            case "stringPickerSegue" :
                let stringPicker = segue.destination as! StringPickerViewController
                
                // Display the picker with the list of available shelves
                
                var displayArray: [String] = Array()
                
                for myItem in shelfList.shelves
                {
                    displayArray.append(myItem.shelfName)
                }
                
                displayArray.append("Remove from current Shelf")
                
                stringPicker.displayArray = displayArray
                stringPicker.delegate = self
                
            case "booksForAuthorSegue" :
                let bookAuthorListView = segue.destination as! booksForAuthorViewController
                
                bookAuthorListView.googleData = googleData
                bookAuthorListView.delegate = self


            default :
                print("iPadViewController - prepare - segue not found \(segue.identifier)")
        }
    }
        
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return myBooks.books.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if myBooks.books[section].state == showStatus
        {
            return myBooks.books[section].books.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell")! as! myBookItem
        
//        cell.lblTitle.text = "\(googleData.books[(indexPath as NSIndexPath).row].bookName) - \(googleData.books[(indexPath as NSIndexPath).row].publishedDate)"
        
        cell.lblTitle.text = myBooks.books[indexPath.section].books[indexPath.row].bookName
        
        var authorName = ""

        for myItem in myBooks.books[indexPath.section].books[indexPath.row].authors
        {
            if authorName != ""
            {
                authorName = authorName + ", "
            }

            authorName = authorName + myItem.authorName
        }
        
        cell.lblAuthor.text = authorName
        
        cell.btnShelf.setTitle(myBooks.books[indexPath.section].books[indexPath.row].shelves[0].shelfName, for: .normal)

        if myBooks.books[indexPath.section].books[indexPath.row].imageUrl == ""
        {
            cell.imgView.isHidden = true
        }
        else
        {
            cell.imgView.isHidden = false

            // check to see if we already have an image for the book
            
            let myImage = myDatabaseConnection.getImage(bookID: myBooks.books[indexPath.section].books[indexPath.row].bookID)
            
            if myImage == nil
            {
                let url = URL(string: myBooks.books[indexPath.section].books[indexPath.row].imageUrl)
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                
                let workingImage = UIImage(data: data!)
                
                myDatabaseConnection.saveImage(myBooks.books[indexPath.section].books[indexPath.row].bookID, image: workingImage!)
                cell.imgView.image = workingImage
            }
            else
            {
                cell.imgView.image = myImage
            }

//            let url = URL(string: googleData.books[indexPath.section].books[indexPath.row].imageUrl)
//            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//            cell.imgView.image = UIImage(data: data!)
        }

        
 print("Book = \(myBooks.books[indexPath.section].books[indexPath.row].bookName) - order = \(myBooks.books[indexPath.section].books[indexPath.row].bookOrder) - \(myBooks.books[indexPath.section].books[indexPath.row].previousBookID)")
        
        cell.bookRecord = myBooks.books[indexPath.section].books[indexPath.row]
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "bookDetailSegue", sender: indexPath)
    }
 
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView?
    {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "bookListSectionHeader") as! myBookSectionItem

        header.lblDescription.font = UIFont.boldSystemFont(ofSize: 16.0)
        header.btnDisclosure.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        
        if myBooks.books[section].state == showStatus
        {
            header.btnDisclosure.setTitle("-", for: .normal)
        }
        else
        {
            header.btnDisclosure.setTitle("+", for: .normal)
        }
        
        header.section = section
        header.currentState = myBooks.books[section].state
        
        if myBooks.books[section].books.count == 1
        {
            header.lblDescription.text = "\(myBooks.books[section].itemName) - \(myBooks.books[section].books.count) book"
        }
        else
        {
            header.lblDescription.text = "\(myBooks.books[section].itemName) - \(myBooks.books[section].books.count) books"
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat
    {
        return 40.0
    }
        
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    {
        return .none
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath)
    {
        let sourceBook = myBooks.books[fromIndexPath.section].books[fromIndexPath.row]
        let targetBook = myBooks.books[toIndexPath.section].books[toIndexPath.row]
        
        print("Source = \(sourceBook.bookName) - \(sourceBook.bookID) - \(sourceBook.bookOrder)")
        print("Target = \(targetBook.bookName) - \(targetBook.bookID) - \(targetBook.bookOrder)")
        
        print("")
        
        
        sourceBook.setBookOrder(parentBookID: targetBook.bookID)
        
//        if tableView == tblTracks
//        {
//            // Make calls in order to change the ordering of the rows
//            mySelectedStyle.tracks[(fromIndexPath as NSIndexPath).row].reorderRows(mySelectedStyle.tracks[(toIndexPath as NSIndexPath).row].styleOrder)
//            
//            mySelectedStyle.reloadTracks()
//            tblTracks.reloadData()
//        }
    }
    
//    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath)
//    {
//        if tableView == tblStyles
//        {
//            if editingStyle == .delete
//            {
//                // Get row details to delete
//                
//                myProgramStyles.styles[(indexPath as NSIndexPath).row].delete()
//                
//                myProgramStyles.reload()
//                tblStyles.reloadData()
//            }
//        }
//        else
//        {
//            if editingStyle == .delete
//            {
//                // Get row details to delete
//                
//                mySelectedStyle.tracks[(indexPath as NSIndexPath).row].delete()
//                
//                mySelectedStyle.reloadTracks()
//                tblTracks.reloadData()
//            }
//        }
//    }
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        performSearch()
        
        return true
    }
    
    @IBAction func btnSearch(_ sender: UIButton)
    {
        performSearch()
    }
    
    func performSearch()
    {
        reloadTable()
    }
    
    @IBAction func btnSort(_ sender: DLRadioButton)
    {
        if sender == btnAscending
        {
            myBooks.sortOrder = sortOrderAscending
        }
        else
        {
            myBooks.sortOrder = sortOrderDescending
        }
        
        setSortOrder()
    }
    
    @IBAction func btnGrouping(_ sender: DLRadioButton)
    {
        switch sender
        {
            case btnByShelf:
                myBooks.sortType = sortTypeShelf
            
            case btnByAuthor:
                myBooks.sortType = sortTypeAuthor
            
            case btnByTitle:
                myBooks.sortType = sortTypeTitle
            
            default:
                print("ipadView - btnGrouping hit default - \(sender)")
        }

        setGrouping()
    }
    
    @IBAction func btnEditOrder(_ sender: UIButton)
    {
        if sender.currentTitle == "Edit Display Order"
        {
            tableBooks.setEditing(true, animated: true)
            btnEditOrder.setTitle("End Edit", for: .normal)
        }
        else
        {
            tableBooks.setEditing(false, animated: true)
            btnEditOrder.setTitle("Edit Display Order", for: .normal)
        }
    }
    
    func setSortOrder()
    {
        if myBooks.sortOrder == sortOrderAscending
        {
            btnAscending.isSelected = true
            btnDescending.isSelected = false
        }
        else
        {
            btnAscending.isSelected = false
            btnDescending.isSelected = true
        }
        
        myBooks.sort()
        
        reloadTable()
    }
    
    func setGrouping()
    {
        switch myBooks.sortType
        {
            case sortTypeShelf:
                btnByShelf.isSelected = true
                btnByAuthor.isSelected = false
                btnByTitle.isSelected = false
                btnEditOrder.isHidden = true
            
            case sortTypeAuthor:
                btnByShelf.isSelected = false
                btnByAuthor.isSelected = true
                btnByTitle.isSelected = false
                btnEditOrder.isHidden = false
            
            case sortTypeTitle:
                btnByShelf.isSelected = false
                btnByAuthor.isSelected = false
                btnByTitle.isSelected = true
                btnEditOrder.isHidden = true
            
            default:
                print("ipadView - setGrouping hit default - \(myBooks.sortType)")
        }
        
        reloadTable()
    }
    
    func googleDataBooksLoaded()
    {
        notificationCenter.removeObserver(goodReadsBookLoadFinished)

        loadShelves()
        
        reloadTable()
    }
    
    func reloadTable()
    {
        googleData.filter = txtSearch.text!
    
        tableBooks.reloadData()
    }
    
    func updateState(_ notification: Notification)
    {
        let section = (notification as NSNotification).userInfo!["section"] as! Int
        let state = (notification as NSNotification).userInfo!["state"] as! String

        myBooks.books[section].state = state
        
        reloadTable()
    }
    
    func loadShelves()
    {
        myShelvesArray.removeAll()
        
        for myShelf in myDatabaseConnection.getShelves()
        {
            let tempItem = Shelf(shelfID: myShelf.shelfID!)
            
            myShelvesArray.append(tempItem)
        }
    }
    
    func myPickerDidFinish(_ index: Int)
    {
        // Go and get the book details from the database
        
        // first need to check to see if we have the remove option
        
        if index >= shelfList.shelves.count
        {
            // remove from current shelf
            selectedBookEntry.removeFromShelf(shelfID: selectedBookEntry.shelves[0].shelfID, googleData: googleData)
            
            // Remove entry from the database
            
            selectedBookEntry.removeFromDatabase()
        }
        else
        {
            selectedBookEntry.moveBetweenShelves(fromShelfID: selectedBookEntry.shelves[0].shelfID, toShelfID: shelfList.shelves[index].shelfID, googleData: googleData)
        }
        
        myBooks.sort()
        
        tableBooks.reloadData()
    }

    func changeBookShelf(_ notification: Notification)
    {
        selectedBookEntry = (notification as NSNotification).userInfo!["book"] as! Book
        
        performSegue(withIdentifier: "stringPickerSegue", sender: row)
    }
}

class myBookItem: UITableViewCell
{
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnShelf: UIButton!
    
    var bookRecord: Book!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnShelf(_ sender: UIButton)
    {
        let selectedDictionary = ["book" : bookRecord!]
        notificationCenter.post(name: changeMainBookShelfFinished, object: nil, userInfo:selectedDictionary)
    }
}

class myBookHeader: UITableViewCell
{
    @IBOutlet weak var btnAuthor: UIButton!
    @IBOutlet weak var btnShelf: UIButton!
    @IBOutlet weak var txtTitle: UILabel!

    var myBooks: booksToDisplay!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnAuthor(_ sender: UIButton)
    {
        myBooks.sortType = sortTypeAuthor
        notificationCenter.post(name: reloadTableValues, object: nil)
    }
    
    @IBAction func btnShelf(_ sender: UIButton)
    {
        myBooks.sortType = sortTypeShelf
        notificationCenter.post(name: reloadTableValues, object: nil)
    }
}

class myBookSectionItem: UITableViewHeaderFooterView
{
    @IBOutlet weak var btnDisclosure: UIButton!
    @IBOutlet weak var lblDescription: UILabel!
   
    var section: Int!
    var currentState: String!
    
    @IBAction func btnDisclosure(_ sender: UIButton)
    {
        var newState: String = ""
        
        if currentState == showStatus
        {
            newState = hideStatus
        }
        else
        {
            newState = showStatus
        }
        
        let selectedDictionary = ["section" : section, "state" : newState] as [String : Any]
        notificationCenter.post(name: sectionStateChanged, object: nil, userInfo:selectedDictionary)
    }
}
