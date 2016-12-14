//
//  Books+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 14/12/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Books {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Books> {
        return NSFetchRequest<Books>(entityName: "Books");
    }

    @NSManaged public var averageRating: String?
    @NSManaged public var bookDescription: String?
    @NSManaged public var bookID: String?
    @NSManaged public var bookName: String?
    @NSManaged public var bookOrder: Int16
    @NSManaged public var changed: Bool
    @NSManaged public var editionInformation: String?
    @NSManaged public var endDate: String?
    @NSManaged public var format: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var iSBN: String?
    @NSManaged public var iSBN13: String?
    @NSManaged public var largeImageURL: String?
    @NSManaged public var link: String?
    @NSManaged public var numPages: String?
    @NSManaged public var publicationDay: String?
    @NSManaged public var publicationMonth: String?
    @NSManaged public var publicationYear: String?
    @NSManaged public var published: String?
    @NSManaged public var publisherID: String?
    @NSManaged public var ratingsCount: String?
    @NSManaged public var smallImageURL: String?
    @NSManaged public var startDate: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var previousBookID: Int16

}
