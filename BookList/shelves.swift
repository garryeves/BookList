//
//  shelves.swift
//  BookList
//
//  Created by Garry Eves on 20/11/16.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import Foundation

class ShelvesList: NSObject
{
    private var myShelves: [Shelf] = Array()

    var shelves: [Shelf]
    {
        get
        {
            return myShelves
        }
    }
    
    override init()
    {
        let myShelvesData = myDatabaseConnection.getShelves()
        
        myShelves.removeAll()
        
        for myIem in myShelvesData
        {
            let tempItem = Shelf(shelfID: myIem.shelfID!, shelfName: myIem.shelfName!, shelfLink: myIem.shelfLink!)
            myShelves.append(tempItem)
        }
    
        myShelves.sort
        {
            if $0.shelfName != $1.shelfName
            {
                return $0.shelfName < $1.shelfName
            }
            else
            {
                return $0.shelfName < $1.shelfName
            }
        }
    }
}

class Shelf: NSObject
{
    private var myShelfID: String = ""
    private var myShelfName: String = ""
    private var myShelfLink: String = ""
    
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

    var shelfLink: String
        {
        get
        {
            return myShelfLink
        }
        set
        {
            myShelfLink = newValue
        }
    }
    
    init(shelfID: String, shelfName: String)
    {
        super.init()
        
        myShelfID = shelfID
        myShelfName = shelfName
        
        save()
    }
    
    init(shelfID: String, shelfName: String, shelfLink: String)
    {
        super.init()
        
        myShelfID = shelfID
        myShelfName = shelfName
        myShelfLink = shelfLink
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
                myShelfLink = myShelf.shelfLink!
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
                myShelfLink = myShelf.shelfLink!
            }
        }
        else
        {
            // New shelf
            
            myShelfName = shelfName
            
            shelfID = "\(myDatabaseConnection.getMinShelfID() - 1)"
            
            save()
        }
    }
    
    func save()
    {
        myDatabaseConnection.saveShelf(myShelfID, shelfName: myShelfName, shelfLink: myShelfLink)
    }
}
