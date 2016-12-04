//
//  StringPickerViewController.swift
//  BookList
//
//  Created by Garry Eves on 2/12/16.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import UIKit

protocol MyPickerDelegate
{
    func myPickerDidFinish(_ index: Int)
}

class StringPickerViewController: UIViewController
{
    var displayArray: [String]!
    var delegate: MyPickerDelegate!
    
    private var selectedRow: Int = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return displayArray!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        return displayArray![row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedRow = row
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return displayArray[row]
    }
    
    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSelect(_ sender: UIBarButtonItem)
    {
        delegate!.myPickerDidFinish(selectedRow)
        dismiss(animated: true, completion: nil)
    }
}
