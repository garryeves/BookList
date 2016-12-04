//
//  BookImage+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 4/12/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension BookImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookImage> {
        return NSFetchRequest<BookImage>(entityName: "BookImage");
    }

    @NSManaged public var bookID: String?
    @NSManaged public var bookImage: NSData?
    @NSManaged public var usedDate: NSDate?

}
