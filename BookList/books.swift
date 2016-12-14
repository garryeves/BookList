//
//  books.swift
//  BookList
//
//  Created by Garry Eves on 20/11/16.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import Foundation

class booksToDisplay: NSObject
{
    private var myBooks: [Book] = Array()
    private var mySortType: String = sortTypeShelf
    private var mySortOrder: String = sortOrderAscending
    private var mySortTypeChanged: Bool = true
    private var mySearchString: String = ""
    private var myDisplayArray: [displayItem] = Array()
    
    var books: [displayItem]
    {
        get
        {
            return myDisplayArray
        }
    }
    
    var sortType: String
    {
        get
        {
            return mySortType
        }
        set
        {
            mySortTypeChanged = true
            mySortType = newValue
            
            sort()
        }
    }
    
    var sortOrder: String
    {
        get
        {
            return mySortOrder
        }
        set
        {
            mySortOrder = newValue
            sort()
        }
    }
    
    var filter: String
    {
        get
        {
            return mySearchString
        }
        set
        {
            mySearchString = newValue
            sort()
        }
    }
    
    override init()
    {
        super.init()
        
        loadBooks()
    }
    
    func sort()
    {
        switch mySortType
        {
            case sortTypeShelf :
                loadBooks()
            
            case sortTypeAuthor :
                loadBooksByAuthor()
            
            case sortTypeTitle:
                loadBooks()
            
            default:
                print("booksToDisplay: Sort - hit default for some reason - \(mySortType)")
        }
        
        myDisplayArray = buildDisplayArray(sortOrder: mySortType)
        
        mySortTypeChanged = false
    }

    private func performSort()
    {
        switch mySortType
        {
            case sortTypeShelf :
                myBooks.sort
                {
                    if $0.shelfString != $1.shelfString
                    {
                        return $0.shelfString < $1.shelfString
                    }
                    else
                    {
                        if $0.sortAuthor != $1.sortAuthor
                        {
                            return $0.sortAuthor < $1.sortAuthor
                        }
                        else
                        {
                            if mySortOrder == sortOrderAscending
                            {
                                return $0.publishedDate < $1.publishedDate
                            }
                            else
                            {
                                return $1.publishedDate < $0.publishedDate
                            }
                        }
                    }
                }
                
            case sortTypeAuthor :
                myBooks.sort
                {
                    if $0.sortAuthor != $1.sortAuthor
                    {
                        return $0.sortAuthor < $1.sortAuthor
                    }
                    else
                    {
                        if mySortOrder == sortOrderAscending
                        {
                            return $0.publishedDate < $1.publishedDate
                        }
                        else
                        {
                            return $1.publishedDate < $0.publishedDate
                        }
                    }
                }
                
            case sortTypeTitle:
                myBooks.sort
                {
                    if $0.bookName != $1.bookName
                    {
                        return $0.bookName < $1.bookName
                    }
                    else
                    {
                        if mySortOrder == sortOrderAscending
                        {
                            return $0.publishedDate < $1.publishedDate
                        }
                        else
                        {
                            return $1.publishedDate < $0.publishedDate
                        }
                    }
                }
                
            default:
                print("booksToDisplay: performSort - hit default for some reason - \(mySortType)")
        }
        
        myDisplayArray = buildDisplayArray(sortOrder: mySortType)
        
        mySortTypeChanged = false
    }

    func loadBooks()
    {
        myBooks.removeAll()
        
        for myItem in myDatabaseConnection.getBooks()
        {
            let myBook = Book(bookID: myItem.bookID!)
            
            myBooks.append(myBook)
        }
        
        performSort()
    }
    
    func loadBooksByAuthor()
    {
        myBooks.removeAll()
        
        for myItem in myDatabaseConnection.getBooks()
        {
            // Need to get the authors for the book as this is needed to ensure that the list sorts correctly
            
            for myAuthors in myDatabaseConnection.getBookAuthor(bookID: myItem.bookID!)
            {
                //                let myAuthor = Author(authorID: myAuthors.authorID!)
                //print("Authro Name = \(myAuthor.authorName)  ID = \(myAuthors.authorID!)")
                let myBook = Book(bookID: myItem.bookID!, sortAuthor: myAuthors.authorID!)
                
                myBooks.append(myBook)
            }
        }
        
        performSort()
    }
    
    private func buildDisplayArray(sortOrder: String) -> [displayItem]
    {
        var displayArray: [displayItem] = Array()
        
        var currentItem: String = ""
        var displayableItem: String = ""
        var workingItem: String = ""
        var workingBookArray: [Book] = Array()
        var displayStatePreservation: [String] = Array()
        var lastBookProcessed: Book!
        
        if !mySortTypeChanged
        {
            for myItem in myDisplayArray
            {
                displayStatePreservation.append(myItem.state)
            }
        }
        
        var sourceArray : [Book] = Array()
        
        if mySearchString == ""
        {
            sourceArray = myBooks
        }
        else
        {
            for myItem in myBooks
            {
                var matchFound: Bool = false
                if myItem.bookName.lowercased().contains(mySearchString.lowercased())
                {
                    matchFound = true
                }
                else
                {
                    // Search through authors
                    
                    for myAuthor in myItem.authors
                    {
                        if myAuthor.authorName.lowercased().contains(mySearchString.lowercased())
                        {
                            matchFound = true
                            break
                        }
                    }
                }
                
                if matchFound
                {
                    sourceArray.append(myItem)
                }
            }
        }
        
        for myBook in sourceArray
        {
            switch mySortType
            {
            case sortTypeShelf:
                workingItem = myBook.shelfString
                
            case sortTypeAuthor:
                workingItem = myBook.sortAuthor
                
            case sortTypeTitle:
                workingItem = myBook.bookName.lowercased()
                
            default:
                print("booksToDisplay - buildDisplayArray hit default - \(mySortType)")
            }
            
            if currentItem != workingItem
            {
                if currentItem == "" && workingBookArray.count == 0
                {
                    // There was nothing for this empty type, so we do not need to go any further
                }
                else
                {
                    // Save the current details into the struct array
                    let tempItem = displayItem(itemName: displayableItem, books: workingBookArray)
                    
                    // Now make sure we keep the state, if sort order not changed
                    
                    if !mySortTypeChanged
                    {
                        if displayArray.count < displayStatePreservation.count
                        {
                            tempItem.state = displayStatePreservation[displayArray.count]
                        }
                    }
                    
                    displayArray.append(tempItem)
                }
                
                currentItem = workingItem
                switch mySortType
                {
                case sortTypeShelf:
                    displayableItem = myBook.shelfString
                    
                case sortTypeAuthor:
                    displayableItem = myBook.sortAuthor
                    
                case sortTypeTitle:
                    displayableItem = myBook.bookName
                    
                default:
                    print("booksToDisplay - buildDisplayArray2 hit default - \(mySortType)")
                }
                
                workingBookArray.removeAll()
            }
            
            // Now lets process the book
            
            // If we are listing via shelf then do not want duplicate books
            
            if mySortType == sortTypeShelf
            {
                if lastBookProcessed == nil || lastBookProcessed.bookID != myBook.bookID
                {
                    workingBookArray.append(myBook)
                }
                
                lastBookProcessed = myBook
            }
            else
            { //By author so show all book entries
                workingBookArray.append(myBook)
            }
        }
        
        let tempItem = displayItem(itemName: displayableItem, books: workingBookArray)
        
        // Now make sure we keep the state, if sort order not changed
        
        if !mySortTypeChanged
        {
            if displayStatePreservation.count > 0
            {
                if displayArray.count < displayStatePreservation.count
                {
                    tempItem.state = displayStatePreservation[displayArray.count]
                }
            }
        }
        
        displayArray.append(tempItem)
        
        return displayArray
    }
}


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
    private var mySortAuthor: String = ""
    private var myBookOrder: Int = 0
    private var myPreviousBookID = 0
    
    private let incrementUp = "incrementUp"
    private let incrementDown = "incrementDown"
    
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

    var sortAuthor: String
    {
        get
        {
            return mySortAuthor
        }
    }
    
    var bookOrder: Int
    {
        get
        {
            return myBookOrder
        }
        set
        {
            myBookOrder = newValue
            save()
        }
    }
    
    var previousBookID: Int
    {
        get
        {
            return myPreviousBookID
        }
        set
        {
            myPreviousBookID = newValue
            save()
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
        myBookID = bookID

        // Load Author based on ID from the database
        
        let myStoredBooks = myDatabaseConnection.getBook(bookID: bookID)
        
        if myStoredBooks.count > 0
        {
            // Existing shelf
            
            loadBookFromCoreData(books: myStoredBooks)
        
            loadAuthors()
            loadShelves()
            loadCategories()
        }
        
        mySortAuthor = myAuthorString
    }
    
    init(bookOrder: Int)
    {
        super.init()
        
        // Load Author based on ID from the database
        
        let myStoredBooks = myDatabaseConnection.getBook(bookOrder: bookOrder)
        
        if myStoredBooks.count > 0
        {
            myBookID = myStoredBooks[0].bookID!
            
            loadBookFromCoreData(books: myStoredBooks)

            loadAuthors()
            loadShelves()
            loadCategories()
        }
        
        loadAuthors()
        loadShelves()
        loadCategories()
        
        mySortAuthor = myAuthorString
    }

    init(bookID: String, sortAuthor: String)
    {
        super.init()
        myBookID = bookID
        
        // Load Author based on ID from the database
        
        let myStoredBooks = myDatabaseConnection.getBook(bookID: bookID)
        
        if myStoredBooks.count > 0
        {
            // Existing shelf
            loadBookFromCoreData(books: myStoredBooks)
            mySortAuthor = sortAuthor
            
            loadAuthors()
            loadShelves()
            loadCategories()
        }
    }

    private func loadBookFromCoreData(books: [Books])
    {
        for myBook in books
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
            myBookOrder = Int(myBook.bookOrder)
            myPreviousBookID = Int(myBook.previousBookID)
        }
    }
    
    init(bookID: String, bookName: String, publicationDay: String, publicationYear: String, publicationMonth: String, published: String, ISBN: String, ISBN13: String, imageUrl: String, smallImageUrl: String, largeImageUrl: String, link: String, numPages: String, editionInformation: String, publisherID: String, averageRating: String, ratingsCount: String, bookDescription: String, format: String, startDate: String, endDate: String, sortAuthor: String, bookOrder: Int, previousBookOrder: Int)
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
        myBookOrder = bookOrder
        myPreviousBookID = previousBookOrder
        
        loadAuthors()
        loadShelves()
        loadCategories()

        mySortAuthor = myAuthorString
        
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
        myDatabaseConnection.saveBook(myBookID, bookName: myBookName, publicationDay: myPublicationDay, publicationYear: myPublicationYear, publicationMonth: myPublicationMonth, published: myPublished, ISBN: myIsbn, ISBN13: myIsbn13, imageUrl: myImageUrl, smallImageUrl: mySmallImageUrl, largeImageUrl: myLargeImageUrl, link: myLink, numPages: myNumPages, editionInformation: myEditionInformation, publisherID: myPublisherID, averageRating: myAverageRating, ratingsCount: myRatingsCount, bookDescription: myBookDescription, format: myFormat, startDate: myStartDate, endDate: myEndDate, bookOrder: myBookOrder,             previousBookID: myPreviousBookID)

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
    
    func setBookOrder(parentBookID: String)
    {
        let myParentBook = Book(bookID: parentBookID)
        
        if myParentBook.bookOrder == 0
        { // Top level book so no need to loop through children
            myParentBook.bookOrder = myDatabaseConnection.getNextBookOrderNum()
            
            myPreviousBookID = myParentBook.bookOrder
        }
        else
        { // No top level so need to check for children
            let myFirstChild = Book(bookOrder: myParentBook.bookOrder)
            
            // Now go through any further items in order to ensure maintain the order
            myFirstChild.changeBookOrder(direction: incrementUp)
         
            myPreviousBookID = myParentBook.bookOrder
        }
    }

    func changeBookOrder(direction: String)
    {
        if direction == incrementUp
        {
            // Here we get the next item and perfrom the increment until we have been through them all
            
            let child = Book(bookOrder: myBookOrder)
            
            if child.bookID != ""
            {
                // we have a child
                
                child.changeBookOrder(direction: incrementUp)
                
                child.myPreviousBookID = myBookOrder
            }
        }
        else
        {
            // Here we get the next item and perfrom the decrement until we have been through them all
            
            let child = Book(bookOrder: myBookOrder)
            
            if child.bookID != ""
            {
                // we have a child
                
                child.changeBookOrder(direction: incrementUp)
                
                child.myPreviousBookID = myPreviousBookID
            }
        }
    }
    
    func removeFromDatabase()
    {
        // Delete from shelf
        for myItem in myShelves
        {
            myDatabaseConnection.deleteBookFromShelf(myBookID, shelfID: myItem.shelfID)
        }
        
        // Delete Authors
        for myItem in myAuthors
        {
            myDatabaseConnection.deleteBookAuthor(myBookID, authorName: myItem.authorName)
        }
        
        // Update the bookOrder
        
        changeBookOrder(direction: incrementDown)
        // Delete Book
        
        myDatabaseConnection.deleteBook(myBookID)
    }
}
