//
//  coreDatabase.swift
//  BookList
//
//  Created by Garry Eves on 21/11/16.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class coreDatabase: NSObject
{
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "BookList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func getShelves()->[Shelves]
    {
        let fetchRequest = NSFetchRequest<Shelves>(entityName: "Shelves")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "shelfName", ascending: true)]
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func getMinShelfID()->Int
    {
        var minID: Int = 0
        let fetchRequest = NSFetchRequest<Shelves>(entityName: "Shelves")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "shelfID", ascending: false)]
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            
            for myLoop in fetchResults
            {
                minID = Int(myLoop.shelfID!)!
            }
            
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
        }
        return minID
    }
    
    func getShelf(shelfID: String)->[Shelves]
    {
        let fetchRequest = NSFetchRequest<Shelves>(entityName: "Shelves")
        
        let predicate = NSPredicate(format: "shelfID == \"\(shelfID)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
 
    func getShelf(shelfName: String)->[Shelves]
    {
        let fetchRequest = NSFetchRequest<Shelves>(entityName: "Shelves")
        
        let predicate = NSPredicate(format: "shelfName == \"\(shelfName)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func saveShelf(_ shelfID: String, shelfName: String, shelfLink: String)
    {
        let myShelf = getShelf(shelfID: shelfID)
        
        var mySelectedShelf: Shelves
        if myShelf.count == 0
        {
            mySelectedShelf = NSEntityDescription.insertNewObject(forEntityName: "Shelves", into: persistentContainer.viewContext) as! Shelves
            
            mySelectedShelf.shelfID = shelfID
            mySelectedShelf.shelfName = shelfName
            mySelectedShelf.shelfLink = shelfLink
            mySelectedShelf.changed = false
        }
        else
        {
            mySelectedShelf = myShelf[0]
            mySelectedShelf.shelfName = shelfName
            mySelectedShelf.shelfLink = shelfLink
        }
        
        saveContext()
    }

    func getAuthors()->[Authors]
    {
        let fetchRequest = NSFetchRequest<Authors>(entityName: "Authors")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "authorName", ascending: true)]
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func getAuthor(authorID: String)->[Authors]
    {
        let fetchRequest = NSFetchRequest<Authors>(entityName: "Authors")
        
        let predicate = NSPredicate(format: "authorID == \"\(authorID)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func getAuthor(authorName: String)->[Authors]
    {
        let fetchRequest = NSFetchRequest<Authors>(entityName: "Authors")
        
        let predicate = NSPredicate(format: "authorName == \"\(authorName)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func saveAuthor(_ authorID: String, authorName: String, imageURL: String, smallImageURL: String, link: String, averageRating: String, ratingsCount: String)
    {
        let myAuthor = getAuthor(authorID: authorID)
        
        var mySelectedAuthor: Authors
        if myAuthor.count == 0
        {
            mySelectedAuthor = NSEntityDescription.insertNewObject(forEntityName: "Authors", into: persistentContainer.viewContext) as! Authors
            
            mySelectedAuthor.authorID = authorID
            mySelectedAuthor.authorName = authorName
            mySelectedAuthor.imageURL = imageURL
            mySelectedAuthor.smallImageURL = smallImageURL
            mySelectedAuthor.link = link
            mySelectedAuthor.averageRating = averageRating
            mySelectedAuthor.ratingsCount = ratingsCount
            mySelectedAuthor.changed = false
        }
        else
        {
            mySelectedAuthor = myAuthor[0]
            mySelectedAuthor.authorName = authorName
            mySelectedAuthor.imageURL = imageURL
            mySelectedAuthor.smallImageURL = smallImageURL
            mySelectedAuthor.link = link
            mySelectedAuthor.averageRating = averageRating
            mySelectedAuthor.ratingsCount = ratingsCount
        }
        
        saveContext()
    }

    func getBooks()->[Books]
    {
        let fetchRequest = NSFetchRequest<Books>(entityName: "Books")
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func getBook(bookID: String)->[Books]
    {
        let fetchRequest = NSFetchRequest<Books>(entityName: "Books")
        
        let predicate = NSPredicate(format: "bookID == \"\(bookID)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func getBook(bookName: String, authorName: String)->[Books]
    {
        let fetchRequest = NSFetchRequest<Books>(entityName: "Books")
        
        let predicate = NSPredicate(format: "(bookName == \"\(bookName)\") && (authorName == \"\(authorName)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func saveBook(_ bookID: String, bookName: String, publicationDay: String, publicationYear: String, publicationMonth: String, published: String, ISBN: String, ISBN13: String, imageUrl: String, smallImageUrl: String, largeImageUrl: String, link: String, numPages: String, editionInformation: String, publisherID: String, averageRating: String, ratingsCount: String, bookDescription: String, format: String, startDate: String, endDate: String)
    {
        let myBook = getBook(bookID: bookID)
        
        var mySelectedBook: Books
        if myBook.count == 0
        {
            mySelectedBook = NSEntityDescription.insertNewObject(forEntityName: "Books", into: persistentContainer.viewContext) as! Books
        
            mySelectedBook.bookID = bookID
            mySelectedBook.bookName = bookName
            mySelectedBook.publicationDay = publicationDay
            mySelectedBook.publicationYear = publicationYear
            mySelectedBook.publicationMonth = publicationMonth
            mySelectedBook.published = published
            mySelectedBook.iSBN = ISBN
            mySelectedBook.iSBN13 = ISBN13
            mySelectedBook.imageURL = imageUrl
            mySelectedBook.smallImageURL = smallImageUrl
            mySelectedBook.largeImageURL = largeImageUrl
            mySelectedBook.link = link
            mySelectedBook.numPages = numPages
            mySelectedBook.editionInformation = editionInformation
            mySelectedBook.publisherID = publisherID
            mySelectedBook.averageRating = averageRating
            mySelectedBook.ratingsCount = ratingsCount
            mySelectedBook.bookDescription = bookDescription
            mySelectedBook.format = format
            mySelectedBook.startDate = startDate
            mySelectedBook.endDate = endDate
            mySelectedBook.changed = false
        }
        else
        {
            mySelectedBook = myBook[0]
            mySelectedBook.bookName = bookName
            mySelectedBook.publicationDay = publicationDay
            mySelectedBook.publicationYear = publicationYear
            mySelectedBook.publicationMonth = publicationMonth
            mySelectedBook.published = published
            mySelectedBook.iSBN = ISBN
            mySelectedBook.iSBN13 = ISBN13
            mySelectedBook.imageURL = imageUrl
            mySelectedBook.smallImageURL = smallImageUrl
            mySelectedBook.largeImageURL = largeImageUrl
            mySelectedBook.link = link
            mySelectedBook.numPages = numPages
            mySelectedBook.editionInformation = editionInformation
            mySelectedBook.publisherID = publisherID
            mySelectedBook.averageRating = averageRating
            mySelectedBook.ratingsCount = ratingsCount
            mySelectedBook.bookDescription = bookDescription
            mySelectedBook.format = format
            mySelectedBook.startDate = startDate
            mySelectedBook.endDate = endDate
        }
        
        saveContext()
    }

    func getBookAuthor(authorName: String)->[BookAuthors]
    {
        let fetchRequest = NSFetchRequest<BookAuthors>(entityName: "BookAuthors")
        
        let predicate = NSPredicate(format: "authorName == \"\(authorName)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func getBookAuthor(bookID: String)->[BookAuthors]
    {
        let fetchRequest = NSFetchRequest<BookAuthors>(entityName: "BookAuthors")
        
        let predicate = NSPredicate(format: "bookID == \"\(bookID)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func getBookAuthor(bookID: String, authorName: String)->[BookAuthors]
    {
        let fetchRequest = NSFetchRequest<BookAuthors>(entityName: "BookAuthors")
        
        let predicate = NSPredicate(format: "(bookID == \"\(bookID)\") && (authorID == \"\(authorName)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func saveBookAuthor(_ bookID: String, authorName: String, role: String)
    {
        let myBook = getBookAuthor(bookID: bookID, authorName: authorName)
        
        var mySelectedBook: BookAuthors
        if myBook.count == 0
        {
            mySelectedBook = NSEntityDescription.insertNewObject(forEntityName: "BookAuthors", into: persistentContainer.viewContext) as! BookAuthors
            
            mySelectedBook.bookID = bookID
            mySelectedBook.authorID = authorName
            mySelectedBook.role = role
            mySelectedBook.changed = false
        }
        else
        {
            mySelectedBook = myBook[0]
            mySelectedBook.role = role
        }
        
        saveContext()
    }

    func getBookShelf(shelfID: String)->[BookShelves]
    {
        let fetchRequest = NSFetchRequest<BookShelves>(entityName: "BookShelves")
        
        let predicate = NSPredicate(format: "shelfID == \"\(shelfID)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func getBookShelf(bookID: String)->[BookShelves]
    {
        let fetchRequest = NSFetchRequest<BookShelves>(entityName: "BookShelves")
        
        let predicate = NSPredicate(format: "bookID == \"\(bookID)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func getBookShelf(bookID: String, shelfID: String)->[BookShelves]
    {
        let fetchRequest = NSFetchRequest<BookShelves>(entityName: "BookShelves")
        
        let predicate = NSPredicate(format: "(bookID == \"\(bookID)\") && (shelfID == \"\(shelfID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func saveBookShelf(_ bookID: String, shelfID: String)
    {
        let myBook = getBookShelf(bookID: bookID, shelfID: shelfID)
        
        var mySelectedBook: BookShelves
        if myBook.count == 0
        {
            mySelectedBook = NSEntityDescription.insertNewObject(forEntityName: "BookShelves", into: persistentContainer.viewContext) as! BookShelves
            
            mySelectedBook.bookID = bookID
            mySelectedBook.shelfID = shelfID
            mySelectedBook.changed = false
        }
        
        saveContext()
    }

    func changeBookShelf(_ bookID: String, oldShelfID: String, newShelfID: String)
    {
        let myBook = getBookShelf(bookID: bookID, shelfID: oldShelfID)
        
        var mySelectedBook: BookShelves
        if myBook.count == 0
        {
            mySelectedBook = NSEntityDescription.insertNewObject(forEntityName: "BookShelves", into: persistentContainer.viewContext) as! BookShelves
            
            mySelectedBook.bookID = bookID
            mySelectedBook.shelfID = newShelfID
            mySelectedBook.changed = false
        }
        else
        {
            mySelectedBook = myBook[0]
            mySelectedBook.shelfID = newShelfID
        }
        
        saveContext()
    }
    
    func deleteBookFromShelf(_ bookID: String, shelfID: String)
    {
        let myBook = getBookShelf(bookID: bookID, shelfID: shelfID)
        
        for myItem in myBook
        {
            persistentContainer.viewContext.delete(myItem as NSManagedObject)
        }
        
        saveContext()
    }
    
    func getBookCategory(category: String)->[BookCategories]
    {
        let fetchRequest = NSFetchRequest<BookCategories>(entityName: "BookCategories")
        
        let predicate = NSPredicate(format: "category == \"\(category)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func getBookCategory(bookID: String)->[BookCategories]
    {
        let fetchRequest = NSFetchRequest<BookCategories>(entityName: "BookCategories")
        
        let predicate = NSPredicate(format: "bookID == \"\(bookID)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func getBookCategory(bookID: String, category: String)->[BookCategories]
    {
        let fetchRequest = NSFetchRequest<BookCategories>(entityName: "BookCategories")
        
        let predicate = NSPredicate(format: "(bookID == \"\(bookID)\") && (category == \"\(category)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func saveBookCategory(_ bookID: String, category: String)
    {
        let myBook = getBookCategory(bookID: bookID)
        
        var mySelectedBook: BookCategories
        if myBook.count == 0
        {
            mySelectedBook = NSEntityDescription.insertNewObject(forEntityName: "BookCategories", into: persistentContainer.viewContext) as! BookCategories
            
            mySelectedBook.bookID = bookID
            mySelectedBook.category = category
            mySelectedBook.changed = false
        }
        else
        {
            mySelectedBook = myBook[0]
            mySelectedBook.category = category
        }
        
        saveContext()
    }
    
    func deleteBookFromCategory(_ bookID: String, category: String)
    {
        let myBook = getBookCategory(bookID: bookID, category: category)
        
        for myItem in myBook
        {
            persistentContainer.viewContext.delete(myItem as NSManagedObject)
        }
        
        saveContext()
    }

    
    func getBookCategoryList()->[String]
    {
        var myWorkingArray: [String] = Array()
        
        let fetchRequest = NSFetchRequest<BookCategories>(entityName: "BookCategories")
        
        fetchRequest.propertiesToFetch = ["category"]
        fetchRequest.returnsDistinctResults = true
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            for myItem in fetchResults
            {
                myWorkingArray.append(myItem.category!)
            }
            return myWorkingArray
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }

    func getImage(bookID: String)->UIImage?
    {
        let fetchRequest = NSFetchRequest<BookImage>(entityName: "BookImage")
        
        let predicate = NSPredicate(format: "bookID == \"\(bookID)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            
            if fetchResults.count == 0
            {
                return nil
            }
            else
            {
                return UIImage(data: fetchResults[0].bookImage as! Data)
            }
            
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return nil
        }
    }
    
    private func getImageRecord(bookID: String)->[BookImage]
    {
        let fetchRequest = NSFetchRequest<BookImage>(entityName: "BookImage")
        
        let predicate = NSPredicate(format: "bookID == \"\(bookID)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func saveImage(_ bookID: String, image: UIImage)
    {
        let myImageRecords = getImageRecord(bookID: bookID)
        
        
        // create NSData from UIImage
        guard let imageData = UIImageJPEGRepresentation(image, 1) else {
            // handle failed conversion
            print("jpg error")
            return
        }
        
        var mySelectedImage: BookImage
        if myImageRecords.count == 0
        {
            mySelectedImage = NSEntityDescription.insertNewObject(forEntityName: "BookImage", into: persistentContainer.viewContext) as! BookImage
            mySelectedImage.bookID = bookID
        }
        else
        {
            mySelectedImage = myImageRecords[0]
        }
        
        mySelectedImage.bookImage = imageData as NSData
        mySelectedImage.usedDate = NSDate()
        
        saveContext()
    }
    
    func deleteOldImage()
    {
        let fetchRequest = NSFetchRequest<BookImage>(entityName: "BookImage")
        
        // get the date one month before today
        let myCalendar = Calendar.current
        
        let resultDate = myCalendar.date(byAdding: .month, value: -1, to: Date())!
        
        let predicate = NSPredicate(format: "usedDate <= %@", resultDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        
        do
        {
            let fetchResults = try persistentContainer.viewContext.fetch(fetchRequest)
        
            for myItem in fetchResults
            {
                persistentContainer.viewContext.delete(myItem as NSManagedObject)
            }
        }
        catch
        {
            print("Error ocurred during execution: \(error)")
        }
        
        saveContext()
    }

}
