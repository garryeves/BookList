//
//  ViewController.swift
//  BookList
//
//  Created by Garry Eves on 17/11/16.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import UIKit

class ViewController: UIViewController , GIDSignInUIDelegate
{
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var txtStatus: UILabel!

    //var goodReads: GoodReadsData!
    
    var googleData: GoogleBooks!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Initialise connection to goodreads
        
        notificationCenter.addObserver(self, selector: #selector(self.toggleAuthUI), name: ToggleAuthUINotification, object: nil)
        
//        notificationCenter.addObserver(self, selector: #selector(self.goodReadsDataRefresh), name: goodReadsAuthenticationFinished, object: nil)

//        notificationCenter.addObserver(self, selector: #selector(self.goodReadsShelvesLoaded), name: goodReadsShelfLoadFinished, object: nil)

        myDatabaseConnection = coreDatabase()
        
   //     goodReads = GoodReadsData()
        
       // goodReads.authenticate(sourceViewController: self)
        
        signInButton.isHidden = true
        txtStatus.text = "Connecting to Google"
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/plus.me", "https://www.googleapis.com/auth/userinfo.email", "https://www.googleapis.com/auth/userinfo.profile", "https://www.googleapis.com/auth/books"]
        
        // Uncomment to automatically sign in the user.
       GIDSignIn.sharedInstance().signInSilently()

        
        myDatabaseConnection.deleteOldImage()
        
 //       toggleAuthUI()
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    func goodReadsDataRefresh()
//    {
//        notificationCenter.removeObserver(goodReadsAuthenticationFinished)
//        
//        if goodReads.isAuthenticated
//        {
//            // Go and get the list of shelves from Goodreads, and then make sure we have populated them into the data table
//            
//            goodReads.getShelves()
//            
//            //goodReads.getAllShelfBooks(page:1)
//        }
//        else
//        {
//            print("Not authenticated")
//        }
//    }
//
    func goodReadsShelvesLoaded()
    {
        notificationCenter.removeObserver(goodReadsShelfLoadFinished)
        
       // goodReads.displayBooks()
   
        let pad = self.storyboard!.instantiateViewController(withIdentifier: "iPadMainScreen") as! iPadViewController
        pad.googleData = googleData
        self.present(pad, animated: true, completion: nil)
        
//        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
//        
//        // 2. check the idiom
//        switch (deviceIdiom)
//        {
//            case .pad:
//                let pad = self.storyboard!.instantiateViewController(withIdentifier: "iPadMainScreen") as! iPadViewController
//                pad.googleData = googleData
//                self.present(pad, animated: true, completion: nil)
//            
//            case .phone:
//                let phone = self.storyboard!.instantiateViewController(withIdentifier: "iPhoneMainScreen") as! iPhoneViewController
//                phone.googleData = googleData
//                self.present(phone, animated: true, completion: nil)
//            
//            default:
//                let phone = self.storyboard!.instantiateViewController(withIdentifier: "iPhoneMainScreen") as! iPhoneViewController
//                phone.googleData = googleData
//                self.present(phone, animated: true, completion: nil)
//        }
    }
    
    func toggleAuthUI()
    {
        if (GIDSignIn.sharedInstance().hasAuthInKeychain())
        {
            // Signed in
            signInButton.isHidden = true
            txtStatus.text = "Connected.  Loading Google data"
         
            if googleData == nil
            {
                googleData = GoogleBooks()
            }
            
            googleData.getShelves()
            
            goodReadsShelvesLoaded()
        }
        else
        {
            signInButton.isHidden = false
            txtStatus.text = "Please login to Google"
        }
    }
    
//    @IBAction func didTapSignOut(sender: AnyObject) {
//        GIDSignIn.sharedInstance().signOut()
//    }
    
//    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
//                withError error: NSError!) {
//        if (error == nil) {
//            // Perform any operations on signed in user here.
//            // ...
//        } else {
//            println("\(error.localizedDescription)")
//        }
//    }
    
}

