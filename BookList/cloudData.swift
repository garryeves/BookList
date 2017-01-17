//
//  cloudData.swift
//  BookList
//
//  Created by Garry Eves on 14/12/16.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitInteraction: NSObject
{
    //   let userInfo : UserInfo
    private var container : CKContainer
    //    let publicDB : CKDatabase
    private var privateDB : CKDatabase
    private var publicDB : CKDatabase
    private var myDeviceID: String!
    private var myDeviceName: String!
    private var syncStartDate: Date!
    
    private let coreDataSleepTime: UInt32 = 1000
    private var syncType: String!
    
    private var txnInProgress: Bool = false
    
    override init()
    {
        #if os(iOS)
            container = CKContainer.default()
        #elseif os(OSX)
            container = CKContainer.init(identifier: "iCloud.com.garryeves.BookList")
        #else
            NSLog("Unexpected OS")
        #endif
        
        let sem = DispatchSemaphore(value: 0)
        
        // Check for connection to Internet
        
        container.accountStatus(completionHandler: {status, error in
            switch status {
            case .available, .restricted:
                break
                
            case .couldNotDetermine, .noAccount:
                break
                // Ask user to login to iCloud
            }
            sem.signal()
        })
        
        sem.wait()
        
        privateDB = container.privateCloudDatabase // this is the one to use to save the data
        publicDB = container.publicCloudDatabase // this is the one to use to save the data
        
        let myDevice = UIDevice.current
        myDeviceID = String(describing: myDevice.identifierForVendor!)
        myDeviceName = String(describing: myDevice.name)
        
        super.init()
        
        //        let _ = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.backgroundSync), userInfo: nil, repeats: false)
    }
    
    func syncAllToCloud()
    {
        let lastUpdateTime = getDeviceRecords()
        saveBookOrder(lastUpdate: lastUpdateTime)
    }
    
    private func getDeviceRecords() -> Date
    {
        var returnDate: Date = defaultDate
        
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: "Devices", predicate: predicate)
        
        let sem = DispatchSemaphore(value: 0)
        
        privateDB.perform(query, inZoneWith: nil) { results , error in
            
            if error != nil
            {
                print("Error = \(error)")
            }
            
            for record in results!
            {
                // Now need to see if we have a match for the device ID
                
                if record.object(forKey: "DeviceID") as! String == self.myDeviceID
                {
                    returnDate = record.object(forKey: "LastUpdated") as! Date
                }
                
                //      self.updateContextRecord(record)
            }
            sem.signal()
        }
        
        sem.wait()
        
        
        if returnDate == defaultDate
        {
            syncType = "Full"
        }
        return returnDate
    }
    
    private func saveDeviceRecord(syncDate: Date)
    {
        let predicate = NSPredicate(format: "DeviceID == \"\(myDeviceID!)\"")
        
        let query = CKQuery(recordType: "Devices", predicate: predicate)
        
        privateDB.perform(query, inZoneWith: nil) { results , error in
            if error != nil
            {
                print("Error = \(error)")
            }
            else
            {
                if results!.count > 0
                {
                    // Existing record so update
                    let record = results!.first! // as! CKRecord
                    
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    record.setValue(self.myDeviceName!, forKey: "DeviceName")
                    record.setValue(syncDate, forKey: "LastUpdated")
                    
                    // Save this record again
                    self.privateDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                        }
                    })
                }
                else
                {
                    // New record so insert
                    let record = CKRecord(recordType: "Devices")
                    
                    record.setValue(self.myDeviceID!, forKey: "DeviceID")
                    record.setValue(self.myDeviceName!, forKey: "DeviceName")
                    record.setValue(syncDate, forKey: "LastUpdated")
                    
                    self.privateDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                        }
                    })
                }
            }
        }
    }
    
    func deleteDeviceRecord()
    {
        let predicate = NSPredicate(format: "DeviceID == \"\(myDeviceID!)\"")
        
        let query = CKQuery(recordType: "Devices", predicate: predicate)
        
        let sem = DispatchSemaphore(value: 0)
        
        privateDB.perform(query, inZoneWith: nil)
        { results , error in
            if error != nil
            {
                print("Error = \(error)")
            }
            else
            {
                for record in results!
                {
                    self.syncStartDate = record.object(forKey: "LastUpdated") as! Date
                    
                    self.privateDB.delete(withRecordID: record.recordID, completionHandler:
                        { (id: CKRecordID?, error: Error?) -> Void in
                            if error != nil
                            {
                                print("Error deleting record", error!)
                            }
                    })
                }
            }
            sem.signal()
        }
        sem.wait()
    }
    
    private func executeQueryOperation(queryOperation: CKQueryOperation, onOperationQueue operationQueue: OperationQueue)
    {
        // Setup the query operation
        queryOperation.database = privateDB
        
        // Assign a completion handler
        queryOperation.queryCompletionBlock = { (cursor: CKQueryCursor?, error: Error?) -> Void in
            guard error==nil else {
                // Handle the error
                return
            }
            if let queryCursor = cursor {
                let queryCursorOperation = CKQueryOperation(cursor: queryCursor)
                
                queryCursorOperation.recordFetchedBlock = queryOperation.recordFetchedBlock
                
                self.executeQueryOperation(queryOperation: queryCursorOperation, onOperationQueue: operationQueue)
            }
            
            NotificationCenter.default.post(name: myNotificationSyncDone, object: nil)
        }
        
        // Add the operation to the operation queue to execute it
        privateDB.add(queryOperation)
    }
    
    func saveBookOrderToCoreData(lastUpdate: Date = defaultDate)
    {
        var predicate: NSPredicate!
        
        if lastUpdate == defaultDate
        {
            predicate = NSPredicate(format: "TRUEPREDICATE")
        }
        else
        {
            predicate = NSPredicate(format: "updateTime >= %@", lastUpdate as CVarArg)
        }
        
        let query = CKQuery(recordType: "bookOrder", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            // Check the update times, if the local record was written after the remote on then we take no action
            
            while self.txnInProgress
            {
                usleep(100)
            }
            
            self.txnInProgress = true
            
            let remoteDate = record.object(forKey: "updateTime") as! Date
            let myRecords = myDatabaseConnection.getBook(bookID: record.object(forKey: "bookID") as! String)
            
            var localDate = defaultDate
            
            for myItem in myRecords
            {
                if myItem.updateTime as! Date > localDate
                {
                    localDate = myItem.updateTime as! Date
                }
            }
            
            if remoteDate > localDate
            {
                // Must be an insert or update
                myDatabaseConnection.syncBookOrder(record.object(forKey: "bookID") as! String,
                                                   bookOrder: record.object(forKey: "sortOrder") as! Int,
                                                   previousBookID: record.object(forKey: "previousBookID") as! Int,
                                                   updateTime: record.object(forKey: "updateTime") as! NSDate)
                
                usleep(self.coreDataSleepTime)
            }
            self.txnInProgress = false
        }
        
        let operationQueue = OperationQueue()
        
        executeQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
    }

    private func connected() -> Bool
    {
        var connected = false
        
        //  let predicate = NSPredicate(value: true)
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: "Devices", predicate: predicate)
        
        let sem = DispatchSemaphore(value: 0)
        
        privateDB.perform(query, inZoneWith: nil) { results , error in
            if error != nil
            {
                print("Error = \(error)")
            }
            else
            {
                connected = true
            }
            
            sem.signal()
        }
        
        sem.wait()
        
        return connected
    }
    
    private func saveBookOrder(lastUpdate: Date = defaultDate)
    {
        let startSync = Date()
        
        // Is the device connected to the Internet
        
        if connected()
        {
            // Get list of items to save
            
            let myBookRecords = myDatabaseConnection.getBooks(lastUpdate: lastUpdate)
            
            for myItem in myBookRecords
            {
                saveBookOrderToCloud(workingRecord: myItem)
            }
            
            saveDeviceRecord(syncDate: startSync)
        }
    }

    func saveBookOrder(book: Book)
    {
        let startSync = Date()
        
        // Is the device connected to the Internet
        
        if connected()
        {
            // Get list of items to save
            
            let myBookRecords = myDatabaseConnection.getBook(bookID: book.bookID)
            
            for myItem in myBookRecords
            {
                saveBookOrderToCloud(workingRecord: myItem)
            }
            
            saveDeviceRecord(syncDate: startSync)
        }
    }
    
    private func saveBookOrderToCloud(workingRecord: Books)
    {
        let predicate = NSPredicate(format: "bookID == \"\(workingRecord.bookID!)\"")
        
        let query = CKQuery(recordType: "bookOrder", predicate: predicate)
        
        privateDB.perform(query, inZoneWith: nil) { results , error in
            if error != nil
            {
                print("Error = \(error)")
            }
            else
            {
                var recordFound: Bool = false
                
                //                if results!.count > 0
                for record in results!
                {
                    // Now we need to check to see if there is an issue with program with same number created on another device
                    
                    // let record = results!.first! // as! CKRecord
                    
                    recordFound = true
                    
                    self.updateBookOrderRecord(workingRecord: workingRecord, record: record)
                }
                
                if !recordFound
                {
                    // New record so insert
                    self.insertBookOrderRecord(workingRecord: workingRecord)
                }
            }
        }
    }
    
    private func updateBookOrderRecord(workingRecord: Books, record: CKRecord)
    {
        // Check the timestamp for the records.  If the remote record was updated after the local one then we should not update
        
        let localTimestamp = workingRecord.updateTime as! Date
        let remoteTimeStamp = record.object(forKey: "updateTime") as! Date
        
        if localTimestamp.compare(remoteTimeStamp) == .orderedDescending || localTimestamp.compare(remoteTimeStamp) == .orderedSame
        {
            record.setValue(workingRecord.bookOrder, forKey: "sortOrder")
            record.setValue(workingRecord.previousBookID, forKey: "previousBookID")
            record.setValue(Date(), forKey: "updateTime")
            
            // Save this record
            self.privateDB.save(record, completionHandler: { (savedRecord, saveError) in
                if saveError != nil
                {
                    NSLog("Error saving record: bookID = \(workingRecord.bookID) - \(saveError!.localizedDescription) ")
                }
            })
        }
    }
    
    private func insertBookOrderRecord(workingRecord: Books)
    {
        let record = CKRecord(recordType: "bookOrder")
        
        record.setValue(workingRecord.bookID, forKey: "bookID")
        record.setValue(workingRecord.bookOrder, forKey: "sortOrder")
        record.setValue(workingRecord.previousBookID, forKey: "previousBookID")
        record.setValue(Date(), forKey: "updateTime")
        
        self.privateDB.save(record, completionHandler: { (savedRecord, saveError) in
            if saveError != nil
            {
                NSLog("Error saving record: bookID = \(workingRecord.bookID) - \(saveError!.localizedDescription)")
            }
        })
    }
}

