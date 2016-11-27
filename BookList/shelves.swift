//
//  shelves.swift
//  BookList
//
//  Created by Garry Eves on 20/11/16.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import Foundation

class Shelf: NSObject
{
    private var myShelfID: String = ""
    private var myShelfName: String = ""
    
    var shelfID: String
    {
        get
        {
            return myShelfID
        }
        set
        {
            myShelfID = newValue
        }
    }

    var shelfName: String
    {
        get
        {
            return myShelfName
        }
        set
        {
            myShelfName = newValue
        }
    }

    init(shelfID: String, shelfName: String)
    {
        super.init()
        
        myShelfID = shelfID
        myShelfName = shelfName
        
        save()
    }
    
    init(shelfID: String)
    {
        super.init()
        // Load shelf based on ID from the database

        let myStoredShelves = myDatabaseConnection.getShelf(shelfID: shelfID)
    
        if myStoredShelves.count > 0
        {
            // Existing shelf
    
            myShelfID = shelfID
            
            for myShelf in myStoredShelves
            {
                myShelfName = myShelf.shelfName!
            }
        }
    }
    
    init(shelfName: String)
    {
        super.init()
        // Load shelf based on Name from the database
        
        let myStoredShelves = myDatabaseConnection.getShelf(shelfName: shelfName)
        
        if myStoredShelves.count > 0
        {
            // Existing shelf
            
            myShelfName = shelfName
            
            for myShelf in myStoredShelves
            {
                myShelfID = myShelf.shelfID!
            }
        }
    }
    
    func save()
    {
        myDatabaseConnection.saveShelf(myShelfID, shelfName: myShelfName)
    }
}
