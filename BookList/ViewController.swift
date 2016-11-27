//
//  ViewController.swift
//  BookList
//
//  Created by Garry Eves on 17/11/16.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var goodReads: GoodReadsData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Initialise connection to goodreads
        
        notificationCenter.addObserver(self, selector: #selector(self.goodReadsDataRefresh), name: goodReadsAuthenticationFinished, object: nil)

        notificationCenter.addObserver(self, selector: #selector(self.goodReadsShelvesLoaded), name: goodReadsShelfLoadFinished, object: nil)

        myDatabaseConnection = coreDatabase()
        
        goodReads = GoodReadsData()
        
        goodReads.authenticate(sourceViewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func goodReadsDataRefresh()
    {
        notificationCenter.removeObserver(goodReadsAuthenticationFinished)
        
        if goodReads.isAuthenticated
        {
            // Go and get the list of shelves from Goodreads, and then make sure we have populated them into the data table
            
            goodReads.getShelves()
            
            //goodReads.getAllShelfBooks(page:1)
        }
        else
        {
            print("Not authenticated")
        }
    }

    func goodReadsShelvesLoaded()
    {
        notificationCenter.removeObserver(goodReadsShelfLoadFinished)
        
       // goodReads.displayBooks()
        
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        
        // 2. check the idiom
        switch (deviceIdiom)
        {
            case .pad:
                let pad = self.storyboard!.instantiateViewController(withIdentifier: "iPadMainScreen") as! iPadViewController
                pad.goodReads = goodReads
                self.present(pad, animated: true, completion: nil)
            
            case .phone:
                let phone = self.storyboard!.instantiateViewController(withIdentifier: "iPhoneMainScreen") as! iPhoneViewController
                phone.goodReads = goodReads
                self.present(phone, animated: true, completion: nil)
            
            default:
                let phone = self.storyboard!.instantiateViewController(withIdentifier: "iPhoneMainScreen") as! iPhoneViewController
                phone.goodReads = goodReads
                self.present(phone, animated: true, completion: nil)
        }
        

    }
}

