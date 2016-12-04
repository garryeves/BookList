//
//  authors.swift
//  BookList
//
//  Created by Garry Eves on 20/11/16.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import Foundation

class Author: NSObject
{
    private var myAuthorID: String = ""
    private var myAuthorName: String = ""
    private var myRole: String = ""
    private var myImageUrl: String = ""
    private var mySmallImageUrl: String = ""
    private var myLink: String = ""
    private var myAverageRating: String = ""
    private var myRatingsCount: String = ""
    
    var authorID: String
    {
        get
        {
            return myAuthorID
        }
        set
        {
            myAuthorID = newValue
        }
    }

    var authorName: String
    {
        get
        {
            return myAuthorName
        }
        set
        {
            myAuthorName = newValue
        }
    }

    var role: String
    {
        get
        {
            return myRole
        }
        set
        {
            myRole = newValue
        }
    }

    var imageURL: String
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

    var smallImageURL: String
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

//    init(authorID: String)
//    {
//        super.init()
//        // Load Author based on ID from the database
//        
//        let myStoredAuthors = myDatabaseConnection.getAuthor(authorID: authorID)
//        
//        if myStoredAuthors.count > 0
//        {
//            // Existing shelf
//            
//            myAuthorID = authorID
//            
//            for myAuthor in myStoredAuthors
//            {
//                myAuthorName = myAuthor.authorName!
//                myImageUrl = myAuthor.imageURL!
//                mySmallImageUrl = myAuthor.smallImageURL!
//                myLink = myAuthor.link!
//                myAverageRating = myAuthor.averageRating!
//                myRatingsCount = myAuthor.ratingsCount!
//            }
//        }
//    }
    
    init(authorName: String)
    {
        super.init()
        // Load Author based on name from the database
        
        let myStoredAuthors = myDatabaseConnection.getAuthor(authorName: authorName)
        
        if myStoredAuthors.count > 0
        {
            // Existing shelf
            
            myAuthorName = authorName
            
            for myAuthor in myStoredAuthors
            {
                myAuthorID = myAuthor.authorID!
                myImageUrl = myAuthor.imageURL!
                mySmallImageUrl = myAuthor.smallImageURL!
                myLink = myAuthor.link!
                myAverageRating = myAuthor.averageRating!
                myRatingsCount = myAuthor.ratingsCount!
            }
        }
        else
        {
            myAuthorName = authorName
            
            save()
        }
    }
    
//    init(authorID: String, authorName: String, imageURL: String, smallImageURL: String, link: String, averageRating: String, ratingsCount: String)
//    {
//        super.init()
//        
//        // First check to see if there is an existing entry
//        
//        myAuthorID = authorID
//        myAuthorName = authorName
//        myImageUrl = imageURL
//        mySmallImageUrl = smallImageURL
//        myLink = link
//        myAverageRating = averageRating
//        myRatingsCount = ratingsCount
//        
//        save()
//    }

    func save()
    {
        myDatabaseConnection.saveAuthor(myAuthorID, authorName: myAuthorName, imageURL: myImageUrl, smallImageURL: mySmallImageUrl, link: myLink, averageRating: myAverageRating, ratingsCount: myRatingsCount)
    }
}
