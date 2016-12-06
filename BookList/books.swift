//
//  books.swift
//  BookList
//
//  Created by Garry Eves on 20/11/16.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import Foundation

class displayItem
{
    private var myItemName: String = ""
    private var myBooks: [Book]
    private var myState: String = hideStatus
    
    var itemName: String
    {
        get
        {
            return myItemName
        }
    }

    var books: [Book]
    {
        get
        {
            return myBooks
        }
    }

    var state: String
    {
        get
        {
            return myState
        }
        set
        {
            myState = newValue
        }
    }

    init(itemName: String, books: [Book])
    {
        myItemName = itemName
        myBooks = books
    }
}

class Book: NSObject
{
    private var myBookID: String = ""
    private var myBookName: String = ""
    private var myPublicationDay: String = ""
    private var myPublicationYear: String = ""
    private var myPublicationMonth: String = ""
    private var myPublished: String = ""
    private var myIsbn: String = ""
    private var myIsbn13: String = ""
    private var myImageUrl: String = ""
    private var mySmallImageUrl: String = ""
    private var myLargeImageUrl: String = ""
    private var myLink: String = ""
    private var myNumPages: String = ""
    private var myEditionInformation: String = ""
    private var myPublisherID: String = ""
    private var myAverageRating: String = ""
    private var myRatingsCount: String = ""
    private var myBookDescription: String = ""
    private var myFormat: String = ""
    private var myStartDate: String = ""
    private var myEndDate: String = ""
    private var myAuthors: [Author] = Array()
    private var myShelves: [Shelf] = Array()
    private var myCategories: [String] = Array()
    private var myShelfString: String = ""
    private var myAuthorString: String = ""
    
    var bookID: String
    {
        get
        {
            return myBookID
        }
        set
        {
            myBookID = newValue
        }
    }

    var bookName: String
    {
        get
        {
            return myBookName
        }
        set
        {
            myBookName = newValue
        }
    }

//    var publicationDay: String
//    {
//        get
//        {
//            return myPublicationDay
//        }
//        set
//        {
//            myPublicationDay = newValue
//        }
//    }
//
//    var publicationYear: String
//    {
//        get
//        {
//            return myPublicationYear
//        }
//        set
//        {
//            myPublicationYear = newValue
//        }
//    }
//
//    var publicationMonth: String
//    {
//        get
//        {
//            return myPublicationMonth
//        }
//        set
//        {
//            myPublicationMonth = newValue
//        }
//    }

    var published: String
    {
        get
        {
            return myPublished
        }
        set
        {
            myPublished = newValue
        }
    }

    var publishedDate: Date
    {
        get
        {
//            var publicationDay = myPublicationDay
//            var publicationMonth = myPublicationMonth
//            var publicationYear = myPublicationYear
//            
//            if publicationDay == ""
//            {
//                publicationDay = "01"
//            }
//            
//            if publicationMonth == ""
//            {
//                publicationMonth = "01"
//            }
//            
//            if publicationYear == ""
//            {
//                publicationYear = myPublished
//                
//                if publicationYear == ""
//                {
//                    publicationYear = "2001"
//                }
//            }

            var tempString: String = ""
            
            switch myPublished.characters.count
            {
                case 4:
                    // year only
                    tempString = "\(myPublished)-01-01"
                    
                case 7:
                    // year and month
                    tempString = "\(myPublished)-01"
                    
                case 10:
                    
                    // year, month and day
                    tempString = "\(myPublished)"
                    
                default:
                    tempString = "1901-01-01"
            }

            
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateFormat = "yyyy-MM-dd"
            
          //  let workingDateString = "\(publicationDay)/\(publicationMonth)/\(publicationYear)"
            return myDateFormatter.date(from: tempString)!
        }
    }

//    var publishedDateString: String
//    {
//        get
//        {
//            var publicationDay = myPublicationDay
//            var publicationMonth = myPublicationMonth
//            var publicationYear = myPublicationYear
//            
//            if publicationDay == ""
//            {
//                publicationDay = "01"
//            }
//            
//            if publicationMonth == ""
//            {
//                publicationMonth = "01"
//            }
//            
//            if publicationYear == ""
//            {
//                publicationYear = myPublished
//                
//                if publicationYear == ""
//                {
//                    publicationYear = "2001"
//                }
//            }
//            
//            let myDateFormatter = DateFormatter()
//            myDateFormatter.dateFormat = "dd/MM/yyyyy"
//            
//            let workingDateString = "\(publicationDay)/\(publicationMonth)/\(publicationYear)"
//            let workingDate = myDateFormatter.date(from: workingDateString)!
//
//            myDateFormatter.dateFormat = ""
//            myDateFormatter.dateStyle = .medium
//            
//            return myDateFormatter.string(from: workingDate)
//        }
//    }
    
    var isbn: String
    {
        get
        {
            return myIsbn
        }
        set
        {
            myIsbn = newValue
        }
    }

    var isbn13: String
    {
        get
        {
            return myIsbn13
        }
        set
        {
            myIsbn13 = newValue
        }
    }

    var imageUrl: String
    {
        get
        {
            return myImageUrl
        }
        set
        {
            myImageUrl = newValue
        }
    }

    var smallImageUrl: String
    {
        get
        {
            return mySmallImageUrl
        }
        set
        {
            mySmallImageUrl = newValue
        }
    }

    var largeImageUrl: String
    {
        get
        {
            return myLargeImageUrl
        }
        set
        {
            myLargeImageUrl = newValue
        }
    }

    var link: String
    {
        get
        {
            return myLink
        }
        set
        {
            myLink = newValue
        }
    }

    var numPages: String
    {
        get
        {
            return myNumPages
        }
        set
        {
            myNumPages = newValue
        }
    }

    var editionInformation: String
    {
        get
        {
            return myEditionInformation
        }
        set
        {
            myEditionInformation = newValue
        }
    }

    var publisherID: String
    {
        get
        {
            return myPublisherID
        }
        set
        {
            myPublisherID = newValue
        }
    }
    
    var averageRating: String
    {
        get
        {
            return myAverageRating
        }
        set
        {
            myAverageRating = newValue
        }
    }
    
    var ratingsCount: String
    {
        get
        {
            return myRatingsCount
        }
        set
        {
            myRatingsCount = newValue
        }
    }
    
    var bookDescription: String
    {
        get
        {
            return myBookDescription
        }
        set
        {
            myBookDescription = newValue
        }
    }
    
//    var format: String
//    {
//        get
//        {
//            return myFormat
//        }
//        set
//        {
//            myFormat = newValue
//        }
//    }
//
//    var startDateString: String
//    {
//        get
//        {
//            let myDateFormatter = DateFormatter()
//            myDateFormatter.dateFormat = "EEE MMM dd HH.mm.ss xx yyyy"
//            
//            if myStartDate != ""
//            {
//                let workingDate = myDateFormatter.date(from: myStartDate)!
//                
//                myDateFormatter.dateFormat = ""
//                myDateFormatter.dateStyle = .medium
//                
//                return myDateFormatter.string(from: workingDate)
//            }
//            else
//            {
//                return myStartDate
//            }
//        }
//        set
//        {
//            myStartDate = newValue
//        }
//    }
//
//    var startDate: Date
//    {
//        get
//        {
//            let myDateFormatter = DateFormatter()
//            myDateFormatter.dateFormat = "EEE MMM dd HH.mm.ss xx yyyy"
//            
//            return myDateFormatter.date(from: myStartDate)!
//
//        }
//    }
//    
//    var endDateString: String
//    {
//        get
//        {
//            let myDateFormatter = DateFormatter()
//            myDateFormatter.dateFormat = "EEE MMM dd HH.mm.ss xx yyyy"
//            
//            if myEndDate != ""
//            {
//                let workingDate = myDateFormatter.date(from: myEndDate)!
//                
//                myDateFormatter.dateFormat = ""
//                myDateFormatter.dateStyle = .medium
//                
//                return myDateFormatter.string(from: workingDate)
//            }
//            else
//            {
//                return myEndDate
//            }
//        }
//        set
//        {
//            myEndDate = newValue
//        }
//    }
//    
//    var endDate: Date
//    {
//        get
//        {
//            let myDateFormatter = DateFormatter()
//            myDateFormatter.dateFormat = "EEE MMM dd HH.mm.ss ZZZ yyyy"
//            
//            return myDateFormatter.date(from: myEndDate)!
//        }
//    }
    
    var authors: [Author]
    {
        get
        {
            return myAuthors
        }
    }
    
    var shelves: [Shelf]
    {
        get
        {
            return myShelves
        }
    }

    var categories: [String]
    {
        get
        {
            return myCategories
        }
    }
    
    var authorString: String
    {
        get
        {
            return myAuthorString
        }
    }

    var shelfString: String
        {
        get
        {
            return myShelfString
        }
    }

    override init()
    {
        myAuthors.removeAll()
        myShelves.removeAll()
        myCategories.removeAll()
    }
    
    init(bookID: String)
    {
        super.init()

        // Load Author based on ID from the database
        
        let myStoredBooks = myDatabaseConnection.getBook(bookID: bookID)
        
        if myStoredBooks.count > 0
        {
            // Existing shelf
            
            myBookID = bookID
            
            for myBook in myStoredBooks
            {
                myBookName = myBook.bookName!
                myPublicationDay = myBook.publicationDay!
                myPublicationYear = myBook.publicationYear!
                myPublicationMonth = myBook.publicationMonth!
                myPublished = myBook.published!
                myIsbn = myBook.iSBN!
                myIsbn13 = myBook.iSBN13!
                myImageUrl = myBook.imageURL!
                mySmallImageUrl = myBook.smallImageURL!
                myLargeImageUrl = myBook.largeImageURL!
                myLink = myBook.link!
                myNumPages = myBook.numPages!
                myEditionInformation = myBook.editionInformation!
                myPublisherID = myBook.publisherID!
                myAverageRating = myBook.averageRating!
                myRatingsCount = myBook.ratingsCount!
                myBookDescription = myBook.bookDescription!
                myFormat = myBook.format!
                myStartDate = myBook.startDate!
                myEndDate = myBook.endDate!
            }
        }
        
        loadAuthors()
        loadShelves()
        loadCategories()
    }
    
    init(bookID: String, bookName: String, publicationDay: String, publicationYear: String, publicationMonth: String, published: String, ISBN: String, ISBN13: String, imageUrl: String, smallImageUrl: String, largeImageUrl: String, link: String, numPages: String, editionInformation: String, publisherID: String, averageRating: String, ratingsCount: String, bookDescription: String, format: String, startDate: String, endDate: String)
    {
        super.init()

        // First check to see if there is an existing entry
        myBookID = bookID
        myBookName = bookName
        myPublicationDay = publicationDay
        myPublicationYear = publicationYear
        myPublicationMonth = publicationMonth
        myPublished = published
        myIsbn = ISBN
        myIsbn13 = ISBN13
        myImageUrl = imageUrl
        mySmallImageUrl = smallImageUrl
        myLargeImageUrl = largeImageUrl
        myLink = link
        myNumPages = numPages
        myEditionInformation = editionInformation
        myPublisherID = publisherID
        myAverageRating = averageRating
        myRatingsCount = ratingsCount
        myBookDescription = bookDescription
        myFormat = format
        myStartDate = startDate
        myEndDate = endDate
        
        loadAuthors()
        loadShelves()
        loadCategories()

        save()
    }
    
    func loadAuthors()
    {
        myAuthors.removeAll()
        
        myAuthorString = ""
        
        for myItem in myDatabaseConnection.getBookAuthor(bookID: myBookID)
        {
            let myAuthor = Author(authorName: myItem.authorID!)
            
            myAuthor.role = myItem.role!
            
            myAuthors.append(myAuthor)
            
            if myAuthorString != ""
            {
                myAuthorString = myAuthorString + ", "
            }
            
            let tempAuthor = Author(authorName: myItem.authorID!)
            
            myAuthorString = myAuthorString + tempAuthor.authorName
        }
    }
    
    func loadShelves()
    {
        myShelves.removeAll()
        myShelfString = ""
        
        for myItem in myDatabaseConnection.getBookShelf(bookID: myBookID)
        {
            let myShelf = Shelf(shelfID: myItem.shelfID!)
            
            myShelves.append(myShelf)
            
            if myShelfString != ""
            {
                myShelfString = myShelfString + ", "
            }
            
            let tempShelf = Shelf(shelfID: myItem.shelfID!)
            
            myShelfString = myShelfString + tempShelf.shelfName

        }
    }
    
    func loadCategories()
    {
        myCategories.removeAll()

        for myItem in myDatabaseConnection.getBookCategory(bookID: myBookID)
        {
            myCategories.append(myItem.category!)
        }
    }
    
    func addAuthor(authorDetails: Author, role: String)
    {
        saveAuthor(authorName: authorDetails.authorName, role: role)

        loadAuthors()
    }
    
    func removeFromShelf()
    {
        for myItem in myDatabaseConnection.getBookShelf(bookID: myBookID)
        {
            myDatabaseConnection.deleteBookFromShelf(myBookID, shelfID: myItem.shelfID!)
        }
    }
    
    func addToShelf(shelfName: String)
    {
        let myShelf = Shelf(shelfName: shelfName)
        saveShelf(shelfID: myShelf.shelfID)

        loadShelves()
    }
    
    func removeCategories()
    {
        for myItem in myDatabaseConnection.getBookCategory(bookID: myBookID)
        {
            myDatabaseConnection.deleteBookFromCategory(myBookID, category: myItem.category!)
        }
    }
    
    func addCategory(category: String)
    {
        myDatabaseConnection.saveBookCategory(myBookID, category: category)
        
        loadCategories()
    }
    
    func addToShelf(shelfID: String, googleData: GoogleBooks)
    {
        let myShelf = Shelf(shelfID: shelfID)
        saveShelf(shelfID: myShelf.shelfID)

        googleData.googleAssignBookToShelf(bookID: myBookID, shelfID: shelfID)

        loadShelves()
    }

    func removeFromShelf(shelfID: String, googleData: GoogleBooks)
    {
        // Delete from local DB
        
        myDatabaseConnection.deleteBookFromShelf(myBookID, shelfID: shelfID)

        // Delete from Google
        googleData.googleRemoveBookFromShelf(bookID: myBookID, shelfID: shelfID)
    }

    func moveBetweenShelves(fromShelfID: String, toShelfID: String, googleData: GoogleBooks)
    {
        removeFromShelf(shelfID: fromShelfID, googleData: googleData)
        
        addToShelf(shelfID: toShelfID, googleData: googleData)
    }
    
    func save()
    {
        myDatabaseConnection.saveBook(myBookID, bookName: myBookName, publicationDay: myPublicationDay, publicationYear: myPublicationYear, publicationMonth: myPublicationMonth, published: myPublished, ISBN: myIsbn, ISBN13: myIsbn13, imageUrl: myImageUrl, smallImageUrl: mySmallImageUrl, largeImageUrl: myLargeImageUrl, link: myLink, numPages: myNumPages, editionInformation: myEditionInformation, publisherID: myPublisherID, averageRating: myAverageRating, ratingsCount: myRatingsCount, bookDescription: myBookDescription, format: myFormat, startDate: myStartDate, endDate: myEndDate)
        
        for myItem in myAuthors
        {
            saveAuthor(authorName: myItem.authorName, role: myItem.role)
        }
        
        for myItem in myShelves
        {
            saveShelf(shelfID: myItem.shelfID)
        }
    }
    
    private func saveAuthor(authorName: String, role: String)
    {
        myDatabaseConnection.saveBookAuthor(myBookID, authorName: authorName, role: role)
    }
    
    private func saveShelf(shelfID: String)
    {
        myDatabaseConnection.saveBookShelf(myBookID, shelfID: shelfID)
    }
}
