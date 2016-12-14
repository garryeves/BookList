//
//  bookDetailsViewController.swift
//  BookList
//
//  Created by Garry Eves on 24/11/16.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import UIKit

class bookDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MyPickerDelegate
{
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtPublisher: UITextField!
    @IBOutlet weak var txtPublishedYear: UITextField!
    @IBOutlet weak var tblAuthors: UITableView!
    @IBOutlet weak var btnShelf: UIButton!
    @IBOutlet weak var txtPages: UITextField!
    @IBOutlet weak var txtISBN: UITextField!
    @IBOutlet weak var txtISBN13: UITextField!
    @IBOutlet weak var txtAverageRating: UITextField!
    @IBOutlet weak var txtRatingCount: UITextField!
    @IBOutlet weak var btnPublishDate: UIButton!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var webDescription: UIWebView!
    @IBOutlet weak var txtLink: UITextView!
    @IBOutlet weak var imgBook: UIImageView!
    @IBOutlet weak var btnGetBooksForAuthor: UIButton!
    
    var googleData: GoogleBooks!
    var myBooks: booksToDisplay!
    var section: Int!
    var row: Int!
    var delegate: MyMainDelegate!
    
    private var workingAuthors: [Author] = Array()
    private var shelfList: ShelvesList!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    //    tblAuthors.register(UITableViewCell.self, forCellReuseIdentifier: "authorCell")
        
        notificationCenter.addObserver(self, selector: #selector(self.populateScreen), name: goodReadsBookDetailsLoadFinished, object: nil)
        
        tblAuthors.layer.borderColor = UIColor.lightGray.cgColor
        tblAuthors.layer.borderWidth = 0.5
        tblAuthors.layer.cornerRadius = 5.0

        txtLink.layer.borderColor = UIColor.lightGray.cgColor
        txtLink.layer.borderWidth = 0.5
        txtLink.layer.cornerRadius = 5.0

        btnGetBooksForAuthor.isHidden = true
        
        shelfList = ShelvesList()
        
        populateScreen()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        notificationCenter.removeObserver(goodReadsBookDetailsLoadFinished)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "getBooksForAuthorSegue"
        {
            let bookAuthorListView = segue.destination as! booksForAuthorViewController
            
            let workingSender = sender as! IndexPath
            
            bookAuthorListView.googleData = googleData
            bookAuthorListView.authorName = workingAuthors[workingSender.row].authorName
        }
        else if segue.identifier == "stringPickerSegue"
        {
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
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return workingAuthors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "authorCell") as! authorItem
        
        cell.lblAuthor.text = workingAuthors[indexPath.row].authorName
        
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
        performSegue(withIdentifier: "getBooksForAuthorSegue", sender: indexPath)
    }
    
    @IBAction func btnSave(_ sender: UIBarButtonItem)
    {
        if delegate != nil
        {
            delegate.reloadTable()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        if delegate != nil
        {
            delegate.reloadTable()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnFormat(_ sender: UIButton) {
    }
    
    @IBAction func btnStartReading(_ sender: UIButton) {
    }
    
    @IBAction func btnFinishedReading(_ sender: UIButton) {
    }
    
    @IBAction func btnPublishDate(_ sender: UIButton) {
    }
    
    func populateScreen()
    {
        let workingBook = myBooks.books[section].books[row]
        
        workingAuthors = workingBook.authors

        txtTitle.text = workingBook.bookName
        txtPublisher.text = workingBook.publisherID
        txtPublishedYear.text = workingBook.published
//        tblAuthors
        
        var shelfString = ""
        
        for myItem in myDatabaseConnection.getBookShelf(bookID: workingBook.bookID)
        {
            if shelfString != ""
            {
                shelfString = shelfString + ", "
            }
            
            let tempShelf = Shelf(shelfID: myItem.shelfID!)
            
            shelfString = shelfString + tempShelf.shelfName
        }

        if shelfString == ""
        {
            btnShelf.setTitle("Select Shelf", for: .normal)
        }
        else
        {
            btnShelf.setTitle(shelfString, for: .normal)
        }
        
        txtPages.text = workingBook.numPages
        
//        if workingBook.format == ""
//        {
//            btnFormat.setTitle("Select Format", for: .normal)
//        }
//        else
//        {
//            btnFormat.setTitle(workingBook.format, for: .normal)
//        }

        txtISBN.text = workingBook.isbn
        txtISBN13.text = workingBook.isbn13
        
        if workingBook.imageUrl == ""
        {
            imgBook.isHidden = true
        }
        else
        {
            imgBook.isHidden = false
            
            // check to see if we already have an image for the book
            
            let myImage = myDatabaseConnection.getImage(bookID: workingBook.bookID)
            
            if myImage == nil
            {
                let url = URL(string: workingBook.imageUrl)
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                
                let workingImage = UIImage(data: data!)
                
                myDatabaseConnection.saveImage(workingBook.bookID, image: workingImage!)
                imgBook.image = workingImage
            }
            else
            {
                imgBook.image = myImage
            }

 //print("Image = \(workingBook.imageUrl)")
//            let url = URL(string: workingBook.imageUrl)
//            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//            imgBook.image = UIImage(data: data!)
        }
        
        txtLink.text = workingBook.link
        txtAverageRating.text = workingBook.averageRating
        txtRatingCount.text = workingBook.ratingsCount
        webDescription.loadHTMLString(workingBook.bookDescription, baseURL: nil)

//        if workingBook.startDateString == ""
//        {
//            btnStartReading.setTitle("Start Reading", for: .normal)
//        }
//        else
//        {
//            btnStartReading.setTitle(workingBook.startDateString, for: .normal)
//        }
//
//        if workingBook.endDateString == ""
//        {
//            btnFinishedReading.setTitle("Finished Reading", for: .normal)
//        }
//        else
//        {
//            btnFinishedReading.setTitle(workingBook.endDateString, for: .normal)
//        }
        
//        txtEdition.text = workingBook.editionInformation
        
        if workingBook.published == ""
        {
            btnPublishDate.setTitle("Set Date", for: .normal)
        }
        else
        {
            btnPublishDate.setTitle(workingBook.published, for: .normal)
        }

        tblAuthors.reloadData()
    }
    
    func myPickerDidFinish(_ index: Int)
    {
        // Go and get the book details from the database
        
        let workingBook = myBooks.books[section].books[row]
        
        if index >= shelfList.shelves.count
        {
            // remove from current shelf
            workingBook.removeFromShelf(shelfID: workingBook.shelves[0].shelfID, googleData: googleData)
            
            // Remove entry from the database
            
            workingBook.removeFromDatabase()
        }
        else
        {
            workingBook.moveBetweenShelves(fromShelfID: workingBook.shelves[0].shelfID, toShelfID: shelfList.shelves[index].shelfID, googleData: googleData)
        }
        
        btnShelf.setTitle(shelfList.shelves[index].shelfName, for: .normal)
        
        myBooks.sort()
    }
}

class authorItem: UITableViewCell
{
    @IBOutlet weak var lblAuthor: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}
