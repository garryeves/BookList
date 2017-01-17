//
//  globalItems.swift
//  BookList
//
//  Created by Garry Eves on 20/11/16.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import Foundation
import UIKit

var myDatabaseConnection: coreDatabase!
var myCloud: CloudKitInteraction = CloudKitInteraction()

let myRowColour = UIColor(red: 190/255, green: 254/255, blue: 235/255, alpha: 0.25)

let authorOrder = "Sort by Author"
let shelfOrder = "Sort by Shelf"

let sortTypeShelf = "sortByShelfAuthor"
let sortTypeAuthor = "sortByAuthor"
let sortTypeTitle = "sortByTitle"

let sortOrderAscending = "ascending"
let sortOrderDescending = "descending"

let showStatus = "Show"
let hideStatus = "Hide"

var googleUserDetails: GoogleUser!

let defaultDate = Date(timeIntervalSince1970: 0)
