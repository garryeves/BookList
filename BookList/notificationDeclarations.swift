//
//  notificationDeclarations.swift
//  BookList
//
//  Created by Garry Eves on 18/11/16.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import Foundation

let notificationCenter = NotificationCenter.default

let goodReadsAuthenticationFinished = Notification.Name("goodReadsAuthenticationFinished")

let goodReadsBookLoadFinished = Notification.Name("goodReadsBookLoadFinished")
let goodReadsShelfLoadFinished = Notification.Name("goodReadsShelfLoadFinished")
let goodReadsBookDetailsLoadFinished = Notification.Name("goodReadsBookDetailsLoadFinished")

let reloadTableValues = Notification.Name("reloadTableValues")

let sectionStateChanged = Notification.Name("sectionStateChanged")

let googleBooksAuthorLoadFinished = Notification.Name("googleBooksAuthorLoadFinished")
let changeBookShelfFinished = Notification.Name("changeBookShelfFinished")
let changeMainBookShelfFinished = Notification.Name("changeMainBookShelfFinished")


// Appdelegate

let ToggleAuthUINotification = Notification.Name("ToggleAuthUINotification")


// Sync with icloud

let myNotificationSyncDone = Notification.Name("NotificationSyncDone")
