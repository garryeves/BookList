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
    var shelfString: String = ""
    var authorString: String = ""
    
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

    var publicationDay: String
    {
        get
        {
            return myPublicationDay
        }
        set
        {
            myPublicationDay = newValue
        }
    }

    var publicationYear: String
    {
        get
        {
            return myPublicationYear
        }
        set
        {
            myPublicationYear = newValue
        }
    }

    var publicationMonth: String
    {
        get
        {
            return myPublicationMonth
        }
        set
        {
            myPublicationMonth = newValue
        }
    }

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
            var publicationDay = myPublicationDay
            var publicationMonth = myPublicationMonth
            var publicationYear = myPublicationYear
            
            if publicationDay == ""
            {
                publicationDay = "01"
            }
            
            if publicationMonth == ""
            {
                publicationMonth = "01"
            }
            
            if publicationYear == ""
            {
                publicationYear = myPublished
                
                if publicationYear == ""
                {
                    publicationYear = "2001"
                }
            }

            let myDateFormatter = DateFormatter()
            myDateFormatter.dateFormat = "dd/MM/yyyyy"
            
            let workingDateString = "\(publicationDay)/\(publicationMonth)/\(publicationYear)"
            return myDateFormatter.date(from: workingDateString)!
        }
    }

    var publishedDateString: String
    {
        get
        {
            var publicationDay = myPublicationDay
            var publicationMonth = myPublicationMonth
            var publicationYear = myPublicationYear
            
            if publicationDay == ""
            {
                publicationDay = "01"
            }
            
            if publicationMonth == ""
            {
                publicationMonth = "01"
            }
            
            if publicationYear == ""
            {
                publicationYear = myPublished
                
                if publicationYear == ""
                {
                    publicationYear = "2001"
                }
            }
            
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateFormat = "dd/MM/yyyyy"
            
            let workingDateString = "\(publicationDay)/\(publicationMonth)/\(publicationYear)"
            let workingDate = myDateFormatter.date(from: workingDateString)!

            myDateFormatter.dateFormat = ""
            myDateFormatter.dateStyle = .medium
            
            return myDateFormatter.string(from: workingDate)
        }
    }
    
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
    
    var format: String
    {
        get
        {
            return myFormat
        }
        set
        {
            myFormat = newValue
        }
    }

    var startDateString: String
    {
        get
        {
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateFormat = "EEE MMM dd HH.mm.ss xx yyyy"
            
            if myStartDate != ""
            {
                let workingDate = myDateFormatter.date(from: myStartDate)!
                
                myDateFormatter.dateFormat = ""
                myDateFormatter.dateStyle = .medium
                
                return myDateFormatter.string(from: workingDate)
            }
            else
            {
                return myStartDate
            }
        }
        set
        {
            myStartDate = newValue
        }
    }

    var startDate: Date
    {
        get
        {
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateFormat = "EEE MMM dd HH.mm.ss xx yyyy"
            
            return myDateFormatter.date(from: myStartDate)!

        }
    }
    
    var endDateString: String
    {
        get
        {
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateFormat = "EEE MMM dd HH.mm.ss xx yyyy"
            
            if myEndDate != ""
            {
                let workingDate = myDateFormatter.date(from: myEndDate)!
                
                myDateFormatter.dateFormat = ""
                myDateFormatter.dateStyle = .medium
                
                return myDateFormatter.string(from: workingDate)
            }
            else
            {
                return myEndDate
            }
        }
        set
        {
            myEndDate = newValue
        }
    }
    
    var endDate: Date
    {
        get
        {
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateFormat = "EEE MMM dd HH.mm.ss ZZZ yyyy"
            
            return myDateFormatter.date(from: myEndDate)!
        }
    }
    
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

    override init()
    {
        myAuthors.removeAll()
        myShelves.removeAll()
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
    }
    
    init(bookName: String, authorName: String)
    {
        super.init()
        
   print("Need to do this init - bookName: String, authorName: String")
   /*
        // Load Author based on name from the database
        
        let myStoredBooks = myDatabaseConnection.getAuthor(authorName: authorName)
        
        if myStoredBooks.count > 0
        {
            // Existing shelf
            
            myBookName = bookName
            myAuthorName = authorName
            
            for myBook in myStoredBooks
            {
                myBookID = myBook.bookID!
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
 
 */
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

        save()
    }
    
    func loadAuthors()
    {
        myAuthors.removeAll()
        
        authorString = ""
        
        for myItem in myDatabaseConnection.getBookAuthor(bookID: myBookID)
        {
            let myAuthor = Author(authorID: myItem.authorID!)
            
            myAuthor.role = myItem.role!
            
            myAuthors.append(myAuthor)
            
            if authorString != ""
            {
                authorString = authorString + ", "
            }
            
            let tempAuthor = Author(authorID: myItem.authorID!)
            
            authorString = authorString + tempAuthor.authorName
        }

    }
    
    func loadShelves()
    {
        myShelves.removeAll()
        shelfString = ""
        
        for myItem in myDatabaseConnection.getBookShelf(bookID: myBookID)
        {
            let myShelf = Shelf(shelfID: myItem.shelfID!)
            
            myShelves.append(myShelf)
            
            if shelfString != ""
            {
                shelfString = shelfString + ", "
            }
            
            let tempShelf = Shelf(shelfID: myItem.shelfID!)
            
            shelfString = shelfString + tempShelf.shelfName

        }
    }
    
    func addAuthor(authorDetails: Author, role: String)
    {
        saveAuthor(bookID: myBookID, authorID: authorDetails.authorID, role: role)

        loadAuthors()
    }
    
    func addShelf(shelfName: String)
    {
        let myShelf = Shelf(shelfName: shelfName)
        saveShelf(bookID: myBookID, shelfID: myShelf.shelfID)

        loadShelves()
    }
    
    func save()
    {
        myDatabaseConnection.saveBook(myBookID, bookName: myBookName, publicationDay: myPublicationDay, publicationYear: myPublicationYear, publicationMonth: myPublicationMonth, published: myPublished, ISBN: myIsbn, ISBN13: myIsbn13, imageUrl: myImageUrl, smallImageUrl: mySmallImageUrl, largeImageUrl: myLargeImageUrl, link: myLink, numPages: myNumPages, editionInformation: myEditionInformation, publisherID: myPublisherID, averageRating: myAverageRating, ratingsCount: myRatingsCount, bookDescription: myBookDescription, format: myFormat, startDate: myStartDate, endDate: myEndDate)
        
        for myItem in myAuthors
        {
            saveAuthor(bookID: myBookID, authorID: myItem.authorID, role: myItem.role)
        }
        
        for myItem in myShelves
        {
            saveShelf(bookID: myBookID, shelfID: myItem.shelfID)
        }
    }
    
    private func saveAuthor(bookID: String, authorID: String, role: String)
    {
        myDatabaseConnection.saveBookAuthor(bookID, authorID: authorID, role: role)
    }
    
    private func saveShelf(bookID: String, shelfID: String)
    {
        myDatabaseConnection.saveBookShelf(bookID, shelfID: shelfID)
    }
    
}
