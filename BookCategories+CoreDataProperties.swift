//
//  BookCategories+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/11/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension BookCategories {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookCategories> {
        return NSFetchRequest<BookCategories>(entityName: "BookCategories");
    }

    @NSManaged public var bookID: String?
    @NSManaged public var category: String?
    @NSManaged public var changed: Bool

}
