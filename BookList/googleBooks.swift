//
//  googleBooks.swift
//  BookList
//
//  Created by Garry Eves on 29/11/16.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import Foundation
import SwiftyJSON

struct GoogleUser
{
    var userID: String = ""
    var idToken: String = ""
    var fullName: String = ""
    var givenName: String = ""
    var familyName: String = ""
    var email: String = ""
}

struct workingBooksForAuthor
{
    var bookID: String = ""
    var bookName: String = ""
    var published: String = ""
    var publishedDate: Date!
    var imageURL: String = ""
    var authors: [String] = Array()
    var authorString: String = ""
    var currentShelf: String = ""
    var newShelf: String = ""
}

class GoogleBooks: NSObject
{
    let APIKey = "AIzaSyC8Rzw-h0E98pqEyMudBeCFZANTfFEJc1E"
    
    private var myBooks: [Book] = Array()
    private var myWorkingBooks: [Book] = Array()
    private var mySortOrder: String = sortOrderShelf
    private var myDisplayArray: [displayItem]! = Array()
    private var mySortOrderChanged: Bool = true
    private var myAuthorBookArray: [workingBooksForAuthor] = Array()
    private var getRecordsAmount: Int = 40
    private var mySearchString: String = ""
    
    var books: [displayItem]
    {
        get
        {
            return myDisplayArray
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
            mySortOrderChanged = true
            mySortOrder = newValue
            sort()
        }
    }
    
    var authorBooks: [workingBooksForAuthor]
    {
        get
        {
            return myAuthorBookArray
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
            myDisplayArray = buildDisplayArray(sortOrder: mySortOrder)
        }
    }
    
    
    private func getWithOutAuthentication(URLString: String, noParams: Bool = false) -> AnyObject
    {
        var returnValue: AnyObject!
        
        var processURL: URL!
        
        if noParams
        {
            guard let url = URL(string: "\(URLString)?key=\(APIKey)") else {
                print("the url is not valid")
                return "" as AnyObject!
            }
            processURL = url
        }
        else
        {
            guard let url = URL(string: "\(URLString)&key=\(APIKey)") else {
                print("the url is not valid")
                return "" as AnyObject!
            }
            processURL = url
        }
 // print("processURL = \(processURL)")
        let mySession = URLSession.shared
        
        var myRequest = URLRequest(url:processURL)
        myRequest.httpMethod = "GET"
        
        let sem = DispatchSemaphore(value: 0);
        
        mySession.dataTask(with: myRequest, completionHandler: {data, response, error -> Void in
            guard error == nil else {
                print(response!)
                print(error!.localizedDescription)
                return
            }
            guard let data = data else {
                print("no error but no data")
                print(response!)
                return
            }
            guard let _ = try? JSONSerialization.jsonObject(with: data, options: []) else {
                print("the JSON is not valid")
                return
            }
            
            returnValue = data as AnyObject!
            
            sem.signal()
        }).resume()
        
        sem.wait()
        
        return returnValue
    }
    
    private func getWithAuthentication(URLString: String) -> AnyObject
    {
        var returnValue: AnyObject!
        
       // let escapedString = URLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        guard let url = URL(string: URLString) else {
            print("the url is not valid")
            return "" as AnyObject!
        }
        
        let mySession = URLSession.shared
        
        var myRequest = URLRequest(url:url)
        myRequest.httpMethod = "GET"
        myRequest.setValue("Bearer \(GIDSignIn.sharedInstance().currentUser.authentication.accessToken!)", forHTTPHeaderField: "Authorization")
        
        let sem = DispatchSemaphore(value: 0);
        
        mySession.dataTask(with: myRequest, completionHandler: {data, response, error -> Void in
            guard error == nil else {
                print(response!)
                print(error!.localizedDescription)
                return
            }
            guard let data = data else {
                print("no error but no data")
                print(response!)
                return
            }
            guard let _ = try? JSONSerialization.jsonObject(with: data, options: []) else {
                print("the JSON is not valid")
                return
            }
            
            returnValue = data as AnyObject!
            
            sem.signal()
        }).resume()
        
        sem.wait()
        
        return returnValue
    }

    private func postWithAuthentication(URLString: String) -> AnyObject
    {
        var returnValue: AnyObject!
        
        guard let url = URL(string: URLString) else {
            print("the url is not valid")
            return "" as AnyObject!
        }
        
        let mySession = URLSession.shared
        
        var myRequest = URLRequest(url:url)
        myRequest.httpMethod = "POST"
        myRequest.setValue("Bearer \(GIDSignIn.sharedInstance().currentUser.authentication.accessToken!)", forHTTPHeaderField: "Authorization")
        
        let sem = DispatchSemaphore(value: 0);
        
        mySession.dataTask(with: myRequest, completionHandler: {data, response, error -> Void in
            guard error == nil else {
                print(response!)
                print(error!.localizedDescription)
                return
            }
            guard let data = data else {
                print("no error but no data")
                print(response!)
                return
            }
//            guard let _ = try? JSONSerialization.jsonObject(with: data, options: []) else {
//                print("the JSON is not valid")
//                return
//            }
            
            returnValue = data as AnyObject!
            
            sem.signal()
        }).resume()
        
        sem.wait()
        
        return returnValue
    }
    
    func getShelves()
    {
        let result = getWithAuthentication(URLString: "https://www.googleapis.com/books/v1/mylibrary/bookshelves")
        
        let json = JSON(data: result as! Data)

        for myItem in json["items"].array!
        {
//            let access = myItem["access"].string!
//            let created = myItem["created"].string!
            let id = myItem["id"].int!
//            let kind = myItem["kind"].string!
            let selfLink = myItem["selfLink"].string!
            let title = myItem["title"].string!
//            let updated = myItem["updated"].string!
//            var volumeCount: Int = 0
//            if myItem["volumeCount"].int != nil
//            {
//                volumeCount = myItem["volumeCount"].int!
//            }
//            let volumesLastUpdated = myItem["volumesLastUpdated"].string!

            // There are a number of shelves that we do not want to hold as they are "smart" shelves for Google
            
            if title != "Books for you" &&
                title != "Browsing history" &&
                title != "Favorites" &&
                title != "My Google eBooks" &&
                title != "Purchased" &&
                title != "Reviewed" &&
                title != "Recently viewed"
            {
                let myShelf = Shelf(shelfID: "\(id)", shelfName: title)
                myShelf.shelfLink = selfLink
                myShelf.save()
            }
        }
    }
    
    func getBooks()
    {
        // loop though the shelves and use this to get book details
        
        for myShelf in myDatabaseConnection.getShelves()
        {
            getBooksFromGoogle(shelfID: myShelf.shelfID!, shelfName: myShelf.shelfName!)
        }
        
        self.loadBooks()
        
        sort()
        
//        notificationCenter.post(name: goodReadsBookLoadFinished, object: nil)
    }
    
    private func getBooksFromGoogle(shelfID: String, shelfName: String)
    {
        var myBook: Book!
        
//print("Getting for shelf \(shelfName)")
        let result = getWithAuthentication(URLString: "https://www.googleapis.com/books/v1/mylibrary/bookshelves/\(shelfID)/volumes")
        
        if result is String
        {
            print("Error getting a book")
        }
        else
        {
            let json = JSON(data: result as! Data)

            // Check to see if there was an error returned
            
            var continueProcessing: Bool = true
            
            for (key,_):(String, JSON) in json {
                //Do something you want
                if key == "error"
                {
                    continueProcessing = false
                    break
                }
                
                if key == "totalItems"
                {
                    let numItems = json["totalItems"].int!
                    
                    if numItems < 1
                    {
                        continueProcessing = false
                        break
                    }
                }
                break
            }
            
            if continueProcessing
            {
                for myItem in json["items"].array!
                {
                    myBook = processBookRecord(json: myItem, shelfName: shelfName)
                    
                    myWorkingBooks.append(myBook)
                }
            }
        }
    }
    
    private func processBookRecord(json: JSON, shelfName: String) -> Book
    {
        var myBook: Book!

        var bookName: String = ""
        if json["volumeInfo"]["title"].string != nil
        {
            bookName = json["volumeInfo"]["title"].string!
        }
        
        var link: String = ""
        if json["volumeInfo"]["infoLink"].string != nil
        {
            link = json["volumeInfo"]["infoLink"].string!
        }
        
        var bookDescription: String = ""
        if json["volumeInfo"]["description"].string != nil
        {
            bookDescription = json["volumeInfo"]["description"].string!
        }
        
        var published: String = ""
        if json["volumeInfo"]["publishedDate"].string != nil
        {
            published = json["volumeInfo"]["publishedDate"].string!
        }
        
        var publisherID: String = ""
        if json["volumeInfo"]["publisher"].string != nil
        {
            publisherID = json["volumeInfo"]["publisher"].string!
        }
        
        var numPages: String = ""
        if json["volumeInfo"]["pageCount"].string != nil
        {
            numPages = json["volumeInfo"]["pageCount"].string!
        }
        
        var imageURL: String = ""
        if json["volumeInfo"]["imageLinks"]["thumbnail"].string != nil
        {
            imageURL = json["volumeInfo"]["imageLinks"]["thumbnail"].string!
        }
        
        var bookID: String = ""
        if json["id"].string != nil
        {
            bookID = json["id"].string!
        }
        
        var iSBN: String = ""
        var iSBN13: String = ""
        
        if json["volumeInfo"]["industryIdentifiers"].array != nil
        {
            for industryIdentifiers in json["volumeInfo"]["industryIdentifiers"].array!
            {
                switch industryIdentifiers["type"].string!
                {
                case "ISBN_13":
                    iSBN13 = industryIdentifiers["identifier"].string!
                    
                case "ISBN_10":
                    iSBN = industryIdentifiers["identifier"].string!
                    
                default:
                    print("No valid Industry identifier")
                }
            }
        }
        var ratingsCount: String = ""
        var averageRating: String = ""
        
        if json["volumeInfo"]["ratingsCount"].string != nil
        {
            ratingsCount = "\(json["volumeInfo"]["ratingsCount"].string!)"
        }
        
        if json["volumeInfo"]["averageRating"].string != nil
        {
            averageRating = "\(json["volumeInfo"]["averageRating"].string!)"
        }
        
        myBook = Book()
        
        myBook.bookID = bookID
        myBook.bookName = bookName
        myBook.published = published
        myBook.isbn = iSBN
        myBook.isbn13 = iSBN13
        myBook.imageUrl = imageURL
        myBook.link = link
        myBook.numPages = numPages
        myBook.publisherID = publisherID
        myBook.averageRating = averageRating
        myBook.ratingsCount = ratingsCount
        myBook.bookDescription = bookDescription
        
        for myItemAuthor in json["volumeInfo"]["authors"].array!
        {
            let myAuthor = Author(authorName: "\(myItemAuthor)")
            
            myBook.addAuthor(authorDetails: myAuthor, role: "Author")
        }
        
        if shelfName != ""
        {
            myBook.removeFromShelf()
            
            myBook.addToShelf(shelfName: shelfName)
        }
        
        myBook.removeCategories()
        
        if json["volumeInfo"]["categories"].array != nil
        {
            for myCategory in json["volumeInfo"]["categories"].array!
            {
                myBook.addCategory(category: "\(myCategory)")
            }
        }
        
        myBook.save()
        
        return myBook
    }

    func getBookFromGoogle(bookID: String, shelfName: String) -> Book?
    {
        var myBook: Book!
        
   //     let result = getWithAuthentication(URLString: "https://www.googleapis.com/books/v1/volumes/\(bookID)")

        let result = getWithOutAuthentication(URLString: "https://www.googleapis.com/books/v1/volumes/\(bookID)", noParams: true)

        if result is String
        {
            print("Error getting a book")
        }
        else
        {
            let json = JSON(data: result as! Data)
//print("json = \(json)")
            
            // Check to see if there was an error returned
            
            var continueProcessing: Bool = true
            
            for (key,_):(String, JSON) in json {
                //Do something you want
                if key == "error"
                {
                    continueProcessing = false
                    break
                }
                
                if key == "totalItems"
                {
                    let numItems = json["totalItems"].int!
                    
                    if numItems < 1
                    {
                        continueProcessing = false
                        break
                    }
                }
                break
            }
            
            if continueProcessing
            {
                myBook = processBookRecord(json: json, shelfName: shelfName)
                
                myWorkingBooks.append(myBook)
            }
            
            self.loadBooks()
            
            sort()
        }
        
        return myBook
    }
    
    func getBooksForAuthor(authorName: String, startIndex: Int)
    {
 //       print("getBooksForAuthor \(authorName) startIndex = \(startIndex)")
        
        if startIndex == 0
        {
            myAuthorBookArray.removeAll()
        }
        
        let newString = authorName.replacingOccurrences(of: " ", with: "+")
     //   let newString = authorName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

        let result = getWithOutAuthentication(URLString: "https://www.googleapis.com/books/v1/volumes?q=inauthor:\(newString)&orderBy=newest&maxResults=\(getRecordsAmount)&startIndex=\(startIndex)")
        
        
        if result is String
        {
            print("Error getting an Author")
        }
        else
        {
            let json = JSON(data: result as! Data)
            
            // Check to see if there was an error returned
            
            var continueProcessing: Bool = true
 
            
//print("JSON = \(json)")
            var totalItems: Int = 0
            
            if json["totalItems"].int != nil
            {
                totalItems = json["totalItems"].int!
            }
            
            for (key,_):(String, JSON) in json {
                //Do something you want
                if key == "error"
                {
                    continueProcessing = false
                    break
                }
                
                if key == "totalItems"
                {
                    let numItems = json["totalItems"].int!
                    
                    if numItems < 1
                    {
                        continueProcessing = false
                        break
                    }
                }
                break
            }
            
            if continueProcessing
            {
                processSearchBooks(json: json, authorName: authorName)

                // Do we need to loop
            
                if totalItems > startIndex + getRecordsAmount
                {
                    let _ = getBooksForAuthor(authorName: authorName, startIndex: startIndex + getRecordsAmount)
                }
            }
        }
        
        if startIndex == 0
        {
            //sort the entries on published date
            myAuthorBookArray.sort
            {
                if $0.publishedDate != $1.publishedDate
                {
                    return $0.publishedDate < $1.publishedDate
                }
                else
                {
                    return $0.publishedDate < $1.publishedDate
                }
            }

            notificationCenter.post(name: googleBooksAuthorLoadFinished, object: nil)
        }
    }

    func searchBooks(searchTerm: String, startIndex: Int)
    {
        //       print("getBooksForAuthor \(authorName) startIndex = \(startIndex)")
        
        if startIndex == 0
        {
            myAuthorBookArray.removeAll()
        }
        
        let newString = searchTerm.replacingOccurrences(of: " ", with: "+")
        //   let newString = authorName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let result = getWithOutAuthentication(URLString: "https://www.googleapis.com/books/v1/volumes?q='\(newString)'&orderBy=relevance&maxResults=\(getRecordsAmount)&startIndex=\(startIndex)")
        
        
        if result is String
        {
            print("Error searching books")
        }
        else
        {
            let json = JSON(data: result as! Data)
            
            // Check to see if there was an error returned
            
            var continueProcessing: Bool = true
            
            for (key,_):(String, JSON) in json {
                //Do something you want
                if key == "error"
                {
                    continueProcessing = false
                    break
                }
                
                if key == "totalItems"
                {
                    let numItems = json["totalItems"].int!
                    
                    if numItems < 1
                    {
                        continueProcessing = false
                        break
                    }
                }
                break
            }
            
            if continueProcessing
            {
                processSearchBooks(json: json)
                
                // Do we need to loop

                // Get max 2 pages as we are sorting by relevance
                
//                if totalItems > startIndex + getRecordsAmount
                if startIndex > getRecordsAmount 
                {
                    let _ = searchBooks(searchTerm: searchTerm, startIndex: startIndex + getRecordsAmount)
                }
            }
        }
        
        if startIndex == 0
        {
            //sort the entries on published date
//            myAuthorBookArray.sort
//                {
//                    if $0.publishedDate != $1.publishedDate
//                    {
//                        return $0.publishedDate < $1.publishedDate
//                    }
//                    else
//                    {
//                        return $0.publishedDate < $1.publishedDate
//                    }
//            }
            
            notificationCenter.post(name: googleBooksAuthorLoadFinished, object: nil)
        }
    }

    func processSearchBooks(json: JSON, authorName: String = "")
    {
        for myItem in json["items"].array!
        {
            //print("MyItem = \(myItem)")
            var bookName: String = ""
            if myItem["volumeInfo"]["title"].string != nil
            {
                bookName = myItem["volumeInfo"]["title"].string!
            }
            
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateFormat = "yyyy-MM-dd"
            
            var published: String = "01/01/1901"
            var publishedDate: Date!
            publishedDate = myDateFormatter.date(from: "1901-01-01")!
            
            if myItem["volumeInfo"]["publishedDate"].string != nil
            {
                // Here we will manuipulate the date in order to have a consistent format
                
                let workingString = myItem["volumeInfo"]["publishedDate"].string!
                
                var tempString: String = ""
                
                switch workingString.characters.count
                {
                case 4:
                    // year only
                    tempString = "\(workingString)-01-01"
                    
                case 7:
                    // year and month
                    tempString = "\(workingString)-01"
                    
                case 10:
                    
                    // year, month and day
                    tempString = "\(workingString)"
                    
                default:
                    tempString = "1901-01-01"
                }
                
                publishedDate = myDateFormatter.date(from: tempString)!
                
                myDateFormatter.dateFormat = "dd MMM yyyy"
                
                published =  myDateFormatter.string(from: publishedDate)
            }
            
            var bookID: String = ""
            if myItem["id"].string != nil
            {
                bookID = myItem["id"].string!
            }
            
            var imageURL: String = ""
            
            if myItem["volumeInfo"]["imageLinks"]["thumbnail"].string != nil
            {
                imageURL = myItem["volumeInfo"]["imageLinks"]["thumbnail"].string!
                //print("Image = \(imageURL)")
            }
            
            var authorFound: Bool = false
            var authorList: [String] = Array()
            
            if myItem["volumeInfo"]["authors"].array != nil
            {
                for myItemAuthor in myItem["volumeInfo"]["authors"].array!
                {
            
                    if authorName != ""
                    {
                        if "\(myItemAuthor)" == authorName
                        {
                            authorFound = true
                        }
                    }
                    else
                    {
                        authorFound = true
                    }
                    authorList.append("\(myItemAuthor)")
                }
            }
            
            if authorFound
            {
                // First thing is to check that we do not have a duplicate, based on bookID
                
                var bookFound: Bool = false
                
                for myBookItem in myAuthorBookArray
                {
                    if myBookItem.bookID == bookID
                    {
                        bookFound = true
                        break
                    }
                }
                
                if !bookFound
                {
                    var tempAuthors: [String] = Array()
                    var authorString: String = ""
                    
                    for myName in authorList
                    {
                        if authorString != ""
                        {
                            authorString = authorString + ", "
                        }
                        
                        authorString = authorString + myName
                        
                        tempAuthors.append("\(myName)")
                    }
                    
                    // Check to see if we already have this book on record
                    var currentShelf: String = ""
                    
                    for myExistingBook in myDatabaseConnection.getBookShelf(bookID: bookID)
                    {
                        let myShelfName = Shelf(shelfID: myExistingBook.shelfID!)
                        currentShelf = myShelfName.shelfName
                    }
                    
                    let myTemp = workingBooksForAuthor(bookID: bookID,
                                                       bookName: bookName,
                                                       published: published,
                                                       publishedDate: publishedDate,
                                                       imageURL: imageURL,
                                                       authors: tempAuthors,
                                                       authorString: authorString,
                                                       currentShelf: currentShelf,
                                                       newShelf: "")
                    
                    myAuthorBookArray.append(myTemp)
                }
            }
        }
    }
    
    func googleAssignBookToShelf(bookID: String, shelfID: String)
    {
        let result = postWithAuthentication(URLString: "https://www.googleapis.com/books/v1/mylibrary/bookshelves/\(shelfID)/addVolume?volumeId=\(bookID)")
        
        if result is String
        {
            print("Error assigning a book")
        }
        else
        {
            _ = JSON(data: result as! Data)
            
            sort()
//print("JSON = \(json)")
        }
    }
    
    func googleRemoveBookFromShelf(bookID: String, shelfID: String)
    {
        let result = postWithAuthentication(URLString: "https://www.googleapis.com/books/v1/mylibrary/bookshelves/\(shelfID)/removeVolume?volumeId=\(bookID)")
        
        if result is String
        {
            print("Error removing a book")
        }
        else
        {
            _ = JSON(data: result as! Data)
            
            sort()

//print("JSON = \(json)")
        }
    }

    func sort()
    {
        switch mySortOrder
        {
            case sortOrderShelf :
                myBooks.sort
                    {
                        if $0.shelfString != $1.shelfString
                        {
                            return $0.shelfString < $1.shelfString
                        }
                        else
                        {
                            if $0.authorString != $1.authorString
                            {
                                return $0.authorString < $1.authorString
                            }
                            else
                            {
                                return $0.publishedDate < $1.publishedDate
                            }
                        }
                }
                
            case sortOrderAuthor :
                myBooks.sort
                    {
                        if $0.authorString != $1.authorString
                        {
                            return $0.authorString < $1.authorString
                        }
                        else
                        {
                            return $0.publishedDate < $1.publishedDate
                        }
                }
                
            default:
                print("goodreadsdata: Sort - hit default for some reason - \(mySortOrder)")
        }
        
//        myDisplayArray = buildDisplayArray(sourceArray: myBooks, sortOrder: mySortOrder)
        myDisplayArray = buildDisplayArray(sortOrder: mySortOrder)
        
        mySortOrderChanged = false
    }

//    func filter(searchString: String)
//    {
//        mySearchString = searchString
//        myDisplayArray = buildDisplayArray(sortOrder: mySortOrder)
    
//        if mySearchString == ""
//        {
//            myDisplayArray = buildDisplayArray(sourceArray: myBooks, sortOrder: mySortOrder)
//        }
//        else
//        {
//            var workingArray: [Book] = Array()
//            for myItem in myBooks
//            {
//                var matchFound: Bool = false
//                if myItem.bookName.lowercased().contains(mySearchString.lowercased())
//                {
//                    matchFound = true
//                }
//                else
//                {
//                    // Search through authors
//                    
//                    for myAuthor in myItem.authors
//                    {
//                        if myAuthor.authorName.lowercased().contains(mySearchString.lowercased())
//                        {
//                            matchFound = true
//                            break
//                        }
//                    }
//                }
//                
//                if matchFound
//                {
//                    workingArray.append(myItem)
//                }
//            }
//            
//            myDisplayArray = buildDisplayArray(sourceArray: workingArray, sortOrder: mySortOrder)
//        }
//    }
    
//    private func buildDisplayArray(sourceArray: [Book], sortOrder: String) -> [displayItem]
    private func buildDisplayArray(sortOrder: String) -> [displayItem]
    {
        var displayArray: [displayItem] = Array()
        
        var currentItem: String = ""
        var workingItem: String = ""
        var workingBookArray: [Book] = Array()
        var displayStatePreservation: [String] = Array()
        
        if !mySortOrderChanged
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
            if sortOrder == sortOrderShelf
            {
                workingItem = myBook.shelfString
            }
            else
            {
                workingItem = myBook.authorString
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
                    let tempItem = displayItem(itemName: currentItem, books: workingBookArray)
                    
                    // Now make sure we keep the state, if sort order not changed
                    
                    if !mySortOrderChanged
                    {
                        tempItem.state = displayStatePreservation[displayArray.count]
                    }
                    
                    displayArray.append(tempItem)
                }
                currentItem = workingItem
                
                workingBookArray.removeAll()
            }
            
            // Now lets process the book
            
            workingBookArray.append(myBook)
        }
        
        let tempItem = displayItem(itemName: currentItem, books: workingBookArray)
        
        // Now make sure we keep the state, if sort order not changed
        
        if !mySortOrderChanged
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

    private func loadBooks()
    {
        myBooks.removeAll()
        
        for myItem in myDatabaseConnection.getBooks()
        {
            let myBook = Book(bookID: myItem.bookID!)
            
            myBooks.append(myBook)
        }
    }
    
    //Dummy statements
    //for myItem in arrayNames
    //{
    //    print("Title2 = \(myItem)")
    //}
    //
    //
    //for (index,subJson):(String, JSON) in json
    //{
    //    print("Index = \(index)")
    //    print("sub = \(subJson)")
    //}
    //
    //for myItem in json["items"].array!
    //{
    //    print("Item = \(myItem)")
    //    let access = myItem["access"].string!
    

    
    //    func getBookInfo(isbn: String) {
    //        guard let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)") else {
    //            print("the url is not valid")
    //            return
    //        }
    //        let mySession = URLSession.shared
    //
    //
    //        mySession.dataTask(with: url, completionHandler: {data, response, error -> Void in
    //            guard error == nil else {
    //                print(response!)
    //                print(error!.localizedDescription)
    //                return
    //            }
    //            guard let data = data else {
    //                print("no error but no data")
    //                print(response!)
    //                return
    //            }
    //            guard let jsonResult = try? JSONSerialization.jsonObject(with: data, options: []) else {
    //                print("the JSON is not valid")
    //                return
    //            }
    //            print("Book Result = \(jsonResult)")
    //
    //            if let arrayOfTitles = (jsonResult as AnyObject).value(forKeyPath: "items.volumeInfo.title") as? [String] {
    //                print(arrayOfTitles)
    //            }
    //            if let arrayOfAuthors = (jsonResult as AnyObject).value(forKeyPath: "items.volumeInfo.authors") as? [[String]] {
    //                print(arrayOfAuthors)
    //            }
    //        }).resume()
    //    }

}
