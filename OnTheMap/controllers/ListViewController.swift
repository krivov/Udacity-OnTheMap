//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Sergey Krivov on 20.07.15.
//  Copyright (c) 2015 Sergey Krivov. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    
    @IBOutlet weak var mainTable: UITableView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var pinButton : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), landscapeImagePhone: nil, style: UIBarButtonItemStyle.Plain, target: self, action: "addPinAction")
        
        var refreshButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "reloadAction")
        
        
        // add the buttons
        self.navigationItem.rightBarButtonItems = [refreshButton, pinButton]
    }
    
    override func viewWillAppear(animated: Bool) {
        self.reloadUsersData()
    }
    
    //action - add location for current user
    func addPinAction() {
        var postController:UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("postView") as! UIViewController
        self.presentViewController(postController, animated: true, completion: nil)
    }
    
    //action - reload users location
    func reloadAction() {
        self.reloadUsersData()
    }
    
    //action - logout
    @IBAction func logoutAction(sender: UIBarButtonItem) {
        
    }
    
    //reload users data
    func reloadUsersData() {
        var student = [StudentInformation]()
        UdacityClient.sharedInstance().getStudentLocations { users, error in
            if let usersData =  users {
                dispatch_async(dispatch_get_main_queue(), {
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.usersData = usersData
                    self.mainTable.reloadData()
                })
            } else {
                if error != nil {
                    UdacityClient.sharedInstance().showAlert(error!, viewController: self)
                }
            }
        }
    }
    
    // MARK: - tableView functions
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserData", forIndexPath: indexPath) as! UITableViewCell
        
        // set cell data
        let firstName = appDelegate.usersData[indexPath.row].firstName
        let lastName = appDelegate.usersData[indexPath.row].lastName
        
        cell.textLabel?.text = "\(firstName) \(lastName)"
        cell.imageView?.image = UIImage(named: "pin")
        
        return cell
    }
    
    // open url in safari when click
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        UdacityClient.sharedInstance().openURL(appDelegate.usersData[indexPath.row].mediaURL)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.usersData.count
    }
}
