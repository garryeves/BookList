//
//  iPhoneViewController.swift
//  BookList
//
//  Created by Garry Eves on 20/11/16.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import UIKit

class iPhoneViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableBooks: UITableView!
    
    var googleData: GoogleBooks!
    
    private var headerCell: myBookHeader!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        notificationCenter.addObserver(self, selector: #selector(self.googleDataBooksLoaded), name: goodReadsBookLoadFinished, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.reloadTable), name: reloadTableValues, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.updateState(_:)), name: sectionStateChanged, object: nil)
        
        headerCell = tableBooks.dequeueReusableCell(withIdentifier: "headerCell") as! myBookHeader
        headerCell.googleData = googleData
        
        tableBooks.tableHeaderView = headerCell
        
        googleDataBooksLoaded()
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain()
        {
            // Go and get the list of shelves from googleData, and then make sure we have populated them into the data table
            
            googleData.getBooks()
        }
        else
        {
            print("Not authenticated")
        }
        
        let nib = UINib(nibName: "bookListSectionHeader", bundle: nil)
        tableBooks.register(nib, forHeaderFooterViewReuseIdentifier: "bookListSectionHeader")
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return googleData.books.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if googleData.books[section].state == showStatus
        {
            return googleData.books[section].books.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell")! as! myBookItem
        
        //        cell.lblTitle.text = "\(googleData.books[(indexPath as NSIndexPath).row].bookName) - \(googleData.books[(indexPath as NSIndexPath).row].publishedDate)"
        
        cell.lblTitle.text = googleData.books[indexPath.section].books[indexPath.row].bookName
        
        var authorName = ""
        
        for myItem in googleData.books[indexPath.section].books[indexPath.row].authors
        {
            if authorName != ""
            {
                authorName = authorName + ", "
            }
            
            authorName = authorName + myItem.authorName
        }
        
        cell.lblAuthor.text = authorName
        
        var shelfName = ""
        
        for myItem in googleData.books[indexPath.section].books[indexPath.row].shelves
        {
            if shelfName != ""
            {
                shelfName = shelfName + ", "
            }
            
            shelfName = shelfName + myItem.shelfName
        }
        
        
  //      cell.lblShelf.text = shelfName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if ((indexPath as NSIndexPath).row % 2 == 0)
        {
            cell.backgroundColor = myRowColour
        }
        else
        {
            cell.backgroundColor = UIColor.white
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("Tapped - \(indexPath)")
        //  let indexOfTappedRow = visibleRowsPerSection[indexPath.section][indexPath.row]
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView?
    {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "bookListSectionHeader") as! myBookSectionItem
        
        header.lblDescription.font = UIFont.boldSystemFont(ofSize: 16.0)
        header.btnDisclosure.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        
        if googleData.books[section].state == showStatus
        {
            header.btnDisclosure.setTitle("-", for: .normal)
        }
        else
        {
            header.btnDisclosure.setTitle("+", for: .normal)
        }
        
        header.section = section
        header.currentState = googleData.books[section].state
        
        header.lblDescription.text = "\(googleData.books[section].itemName) - \(googleData.books[section].books.count) books"
        
        return header
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat
    {
        return 40.0
    }
    
    func googleDataBooksLoaded()
    {
        notificationCenter.removeObserver(goodReadsBookLoadFinished)
        
        reloadTable()
    }
    
    func reloadTable()
    {
        googleData.sort()
        
        switch googleData.sortOrder
        {
        case sortOrderShelf :
            headerCell.btnShelf.isEnabled = false
            headerCell.btnAuthor.isEnabled = true
            
        case sortOrderAuthor :
            headerCell.btnAuthor.isEnabled = false
            headerCell.btnShelf.isEnabled = true
            
        default:
            print("ipadTableView: Set sort buttons - hit default for some reason - \(googleData.sortOrder)")
        }
        
        tableBooks.reloadData()
    }
    
    func updateState(_ notification: Notification)
    {
        let section = (notification as NSNotification).userInfo!["section"] as! Int
        let state = (notification as NSNotification).userInfo!["state"] as! String
        
        googleData.books[section].state = state
        
        reloadTable()
    }
}
