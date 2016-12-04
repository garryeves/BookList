//
//  Shelves+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/11/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Shelves {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Shelves> {
        return NSFetchRequest<Shelves>(entityName: "Shelves");
    }

    @NSManaged public var changed: Bool
    @NSManaged public var shelfID: String?
    @NSManaged public var shelfName: String?
    @NSManaged public var shelfLink: String?

}
