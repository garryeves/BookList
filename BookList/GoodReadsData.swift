//
//  GoodReadsData.swift
//  BookList
//
//  Created by Garry Eves on 17/11/16.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import UIKit
import OAuthSwift
import SWXMLHash

class GoodReadsData: NSObject
{
    private let APIKey = "nQD4O5Bat2S5ZC9gc8zudA"
    private let APISecret = "7mwcIkMWcbvqDLa1RWE5KOm7Ki5U0VaqQayDxupV6U"
    
    private var authenticated: Bool = false
    private var goodReadsUserID = ""
    private var oAuth: OAuth1Swift!
    private var myBooks: [Book] = Array()
    private var myWorkingBooks: [Book] = Array()
    private var mySortOrder: String = sortOrderShelf
    private var myDisplayArray: [displayItem]!
    private var mySortOrderChanged: Bool = true
    
    override init()
    {
        super.init()
        // Load the data from the database, so we have something to be working with
        
        for myItem in myDatabaseConnection.getBooks()
        {
            let myBook = Book(bookID: myItem.bookID!)
            
            myBooks.append(myBook)
        }
        
        sort()
    }
    
    
    var isAuthenticated: Bool
    {
        get
        {
            return authenticated
        }
    }
    
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
    
    func authenticate(sourceViewController: UIViewController)
    {
        let goodreads = OAuth1Swift(
            consumerKey: APIKey,
            consumerSecret: APISecret,
            requestTokenUrl: "https://www.goodreads.com/oauth/request_token",
            authorizeUrl: "https://www.goodreads.com/oauth/authorize?mobile=1",
            accessTokenUrl: "https://www.goodreads.com/oauth/access_token"
        )
        
        goodreads.allowMissingOAuthVerifier = true
        let safari = SafariURLHandler(viewController: sourceViewController, oauthSwift: goodreads)
        goodreads.authorizeURLHandler = safari

        goodreads.authorize(
            withCallbackURL: URL(string: "BookList://oauth-callback")!,
            // From what I gathered the callback url set here is irrelevant – for this to work
            // you have to set that as the callback url at https://www.goodreads.com/api/keys.
            success:
                {
                    credential, response, parameters in
                    self.oAuth = goodreads
                    self.getUserID()
                },
            failure:
                {
                    error in
                        print("Error = \(error.localizedDescription)")
                        notificationCenter.post(name: goodReadsAuthenticationFinished, object: nil)
                }
        )
    }
    
    //private func getUserID(_ oAuth: OAuth1Swift)
    private func getUserID()
    {
        _ = oAuth.client.get(
            "https://www.goodreads.com/api/auth_user",
            success:
                {
                    response in
                    let xml = SWXMLHash.parse(response.data)
                    if let _ = xml["GoodreadsResponse"]["user"].element?.attribute(by: "id")
                    {
//                        var message = "Token: \n\(oAuth.client.credential.oauthToken)"
//                        message += "\n\nToken Secret: \n\(oAuth.client.credential.oauthTokenSecret)"
//                        message += "\n\nUser ID: \n\(userID)"
//                        print("Success! Message = \(message)")
                        self.goodReadsUserID = (xml["GoodreadsResponse"]["user"].element?.attribute(by: "id")?.text)!
                        self.authenticated = true
                        notificationCenter.post(name: goodReadsAuthenticationFinished, object: nil)
                    }
                },
            failure:
                {
                    error in
                        print("GetUserID Error : \(error.localizedDescription)")
                        notificationCenter.post(name: goodReadsAuthenticationFinished, object: nil)
                }
        )
    }

    func getUserBooks()
    {
        
        //        let requestURL = "https://www.goodreads.com/review/list?v=2&key=\(APIKey)&id=\(goodReadsUserID)&shelf=\(shelf)"
       // let requestURL = "https://www.goodreads.com/owned_books/user?key=\(APIKey)&id=\(goodReadsUserID)&format=xml"
        
        // get a list of shelves that the user has
        
        let requestURL = "https://www.goodreads.com/shelf/list.xml?key=\(APIKey)&id=\(goodReadsUserID)"
     print("request = :\(requestURL):")
        _ = oAuth.client.get(
            requestURL,
            success:
            {
                response in
                
                let xml = SWXMLHash.parse(response.data)
print("Shelf xml = \(xml)")
                for shelf in xml["GoodreadsResponse"]["shelves"]["user_shelf"].all
                {
                    let id = shelf["id"].element!.text!
                    let name = shelf["name"].element!.text!
                    
                    print("Id = \(id)")
                    print("Name = \(name)")
              //      self.getShelfBooks(shelf: id)
                }
                
                print("done")
                
                //                if let userID = xml["GoodreadsResponse"]["user"].element?.attribute(by: "id")
//                {
//                    //                        var message = "Token: \n\(oAuth.client.credential.oauthToken)"
//                    //                        message += "\n\nToken Secret: \n\(oAuth.client.credential.oauthTokenSecret)"
//                    //                        message += "\n\nUser ID: \n\(userID)"
//                    //                        print("Success! Message = \(message)")
//                    self.goodReadsUserID = "\(userID)"
//                    self.authenticated = true
//                    notificationCenter.post(name: goodReadsAuthenticationFinished, object: nil)
//                }
            },
            failure:
            {
                error in
                print("getUserBooks Error : \(error.localizedDescription)")
            }
        )
    }
    
    func getShelves()
    {
        let requestURL = "https://www.goodreads.com/shelf/list.xml?id=(goodReadsUserID).xml&key=\(APIKey)"
        
        _ = oAuth.client.get(
            requestURL,
            success:
            {
                response in
                
                let xml = SWXMLHash.parse(response.data)
                
            //    print("xml = \(xml)")
                
                for shelf in xml["GoodreadsResponse"]["shelves"]["user_shelf"].all
                {
                    let shelfID = shelf["id"].element!.text!
                    let shelfName = shelf["name"].element!.text!
                    
                    let _ = Shelf(shelfID: shelfID, shelfName: shelfName)
                }

                notificationCenter.post(name: goodReadsShelfLoadFinished, object: nil)
        },
            failure:
            {
                error in
                print("getShelfBooks Error : \(error.localizedDescription)")
                notificationCenter.post(name: goodReadsBookLoadFinished, object: nil)
        }
        )
    }

    func getAllShelfBooks(page: Int)
    {
        if page == 1
        {
            myWorkingBooks.removeAll()
        }
        
        let requestURL = "https://www.goodreads.com/review/list/\(goodReadsUserID).xml?key=\(APIKey)&v=2&per_page=200&page=\(page)"
        
        _ = oAuth.client.get(
            requestURL,
            success:
            {
                response in
                
                let xml = SWXMLHash.parse(response.data)
                
                
//print("xml = \(xml)")
                
                for review in xml["GoodreadsResponse"]["reviews"]["review"].all
                {
                    let myBook = Book()
                    
                    myBook.bookID = review["book"]["id"].element!.text!
                    myBook.bookName = review["book"]["title"].element!.text!
                    myBook.publicationDay = review["book"]["publication_day"].element!.text!
                    myBook.publicationYear = review["book"]["publication_year"].element!.text!
                    myBook.publicationMonth = review["book"]["publication_month"].element!.text!
                    myBook.published = review["book"]["published"].element!.text!
                    myBook.isbn = review["book"]["isbn"].element!.text!
                    myBook.isbn13 = review["book"]["isbn13"].element!.text!
                    myBook.imageUrl = review["book"]["image_url"].element!.text!
                    myBook.smallImageUrl = review["book"]["small_image_url"].element!.text!
                    myBook.largeImageUrl = review["book"]["large_image_url"].element!.text!
                    myBook.link = review["book"]["link"].element!.text!
                    myBook.numPages = review["book"]["num_pages"].element!.text!
                    myBook.editionInformation = review["book"]["edition_information"].element!.text!
                    myBook.publisherID = review["book"]["publisher"].element!.text!
                    myBook.averageRating = review["book"]["average_rating"].element!.text!
                    myBook.ratingsCount = review["book"]["ratings_count"].element!.text!
                    myBook.bookDescription = review["book"]["description"].element!.text!
                    myBook.format = review["book"]["format"].element!.text!

                    for authorDetails in review["book"]["authors"].all
                    {
                        let myAuthor = Author(authorID: authorDetails["author"]["id"].element!.text!,
                                              authorName: authorDetails["author"]["name"].element!.text!,
                                              imageURL: authorDetails["author"]["image_url"].element!.text!,
                                              smallImageURL: authorDetails["author"]["small_image_url"].element!.text!,
                                              link: authorDetails["author"]["link"].element!.text!,
                                              averageRating: authorDetails["author"]["average_rating"].element!.text!,
                                              ratingsCount: authorDetails["author"]["ratings_count"].element!.text!)
                        
                        myBook.addAuthor(authorDetails: myAuthor, role: authorDetails["author"]["role"].element!.text!)
                    }
                    
                    for shelfDetails in review["shelves"].all
                    {
                        myBook.addShelf(shelfName: (shelfDetails["shelf"].element?.attribute(by: "name")?.text)!)
                    }
 
                    myBook.startDateString = review["started_at"].element!.text!
                    myBook.endDateString = review["read_at"].element!.text!
        
                    myBook.save()
                    
                    self.myWorkingBooks.append(myBook)
                }
                
                // Check to see if we need next page
                
                let reviewTotal = xml["GoodreadsResponse"]["reviews"].element?.attribute(by: "total")?.text
                let reviewEnd = xml["GoodreadsResponse"]["reviews"].element?.attribute(by: "end")?.text
                
                let intTotal = Int(reviewTotal!)
                let intEnd = Int(reviewEnd!)
                
                if intEnd! < intTotal!
                {
                    self.getAllShelfBooks(page: page + 1)
                }
                else
                {
                    self.myBooks = self.myWorkingBooks
                    self.sort()
                    
                    notificationCenter.post(name: goodReadsBookLoadFinished, object: nil)
                }
        },
            failure:
            {
                error in
                print("getShelfBooks Error : \(error.localizedDescription)")
                notificationCenter.post(name: goodReadsBookLoadFinished, object: nil)
        }
        )
    }
    
    func getBookDetails(myBook: Book)
    {
        //  This is used to get the complete list of a books authors
        
        if Int(myBook.bookID)! > 0
        {
//            let requestURL = "https://www.goodreads.com/book/show/\(myBook.bookID).xml?key=\(APIKey)"
            let requestURL = "https://www.goodreads.com/book/show?id=\(myBook.bookID)&key=\(APIKey)&format=xml"
// print("Request = \(requestURL)")
            _ = oAuth.client.get(
                requestURL,
                success:
                {
                    response in
                    let xml = SWXMLHash.parse(response.data)
                    
                 //   print("xml = \(xml)")
  
                    for authorDetails in xml["GoodreadsResponse"]["book"]["authors"]["author"].all
                    {
                        let myAuthor = Author(authorID: authorDetails["id"].element!.text!,
                                              authorName: authorDetails["name"].element!.text!,
                                              imageURL: authorDetails["image_url"].element!.text!,
                                              smallImageURL: authorDetails["small_image_url"].element!.text!,
                                              link: authorDetails["link"].element!.text!,
                                              averageRating: authorDetails["average_rating"].element!.text!,
                                              ratingsCount: authorDetails["ratings_count"].element!.text!)

                        myBook.addAuthor(authorDetails: myAuthor, role: authorDetails["role"].element!.text!)
                    }
                    notificationCenter.post(name: goodReadsBookDetailsLoadFinished, object: nil)
            },
                failure:
                {
                    error in
                    print("getBookDetails Error : \(error.localizedDescription)")
                    notificationCenter.post(name: goodReadsBookDetailsLoadFinished, object: nil)
            }
            )
        }
    }

    func displayBooks()
    {
        for myBook in myBooks
        {
            print("Book = \(myBook.bookID) - \(myBook.bookName)")
            print("published = \(myBook.publishedDate)")
            print("isbn = \(myBook.isbn)")
            print("isbn13 = \(myBook.isbn13)")
            print("imageUrl = \(myBook.imageUrl)")
            print("smallImageUrl = \(myBook.smallImageUrl)")
            print("largeImageUrl = \(myBook.largeImageUrl)")
            print("link = \(myBook.link)")
            print("numPages = \(myBook.numPages)")
            print("editionInformation = \(myBook.editionInformation)")
            print("publisherID = \(myBook.publisherID)")
            print("averageRating = \(myBook.averageRating)")
            print("ratingsCount = \(myBook.ratingsCount)")
            print("bookDescription = \(myBook.bookDescription)")
            
            for myAuthor in myBook.authors
            {
                print("Author = \(myAuthor.authorID) - \(myAuthor.authorName)")
                print("role = \(myAuthor.role)")
                print("imageURL = \(myAuthor.imageURL)")
                print("smallImageURL = \(myAuthor.smallImageURL)")
                print("link = \(myAuthor.link)")
                print("averageRating = \(myAuthor.averageRating)")
                print("ratingsCount = \(myAuthor.ratingsCount)")
            }
            
            
            for myShelf in myBook.shelves
            {
                print("Shelf = \(myShelf.shelfName)")
            }
            
            print("Start Date = \(myBook.startDateString)")
            
            if myBook.startDateString != ""
            {
                print("Date = \(myBook.startDate)")
            }
            
            print("End Date = \(myBook.endDateString)")
            
            if myBook.endDateString != ""
            {
                print("Date = \(myBook.endDate)")
            }
            
            print("")
            print("")
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

        myDisplayArray = buildDisplayArray(sourceArray: myBooks, sortOrder: mySortOrder)
        
        mySortOrderChanged = false
    }
    
    private func buildDisplayArray(sourceArray: [Book], sortOrder: String) -> [displayItem]
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
            tempItem.state = displayStatePreservation[displayArray.count]
        }
        
        displayArray.append(tempItem)
        
        return displayArray
    }
}
