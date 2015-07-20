//
//  ViewController.swift
//  OnTheMap
//
//  Created by Sergey Krivov on 19.07.15.
//  Copyright (c) 2015 Sergey Krivov. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }
    
    // MARK: - Login actions
    @IBAction func loginAction(sender: UIButton) {
        self.showActivityIndicator()
        
        //hide keyboard
        self.view.endEditing(true)
        
        //request to login user
        UdacityClient.sharedInstance().userLogin(emailField.text, password: passwordField.text) { (result, error) -> Void in
            
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAlert(error!)
                    self.hideActivityIndicator()
                })
            }
            else {
                // show map tab view
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.studentKey = result!
                dispatch_async(dispatch_get_main_queue(), {
                    self.hideActivityIndicator()
                    println("OK - key = \(appDelegate.studentKey)")
                    self.goToNextView()
                })
            }
        }
    }
    
    // TODO: Login with facebook
    @IBAction func loginFacebookAction(sender: UIButton) {
        
    }

    // MARK: - Open signup url
    @IBAction func signupAction(sender: UIButton) {
        // set url
        let signUpURL = "https://www.udacity.com/account/auth#!/signup"
        // open url in browser
        UIApplication.sharedApplication().openURL(NSURL(string: signUpURL)!)
    }
    
    // MARK: - go to next view
    func goToNextView() {
        var tabBarController:UITabBarController = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
        self.presentViewController(tabBarController, animated: true, completion: nil)
    }
    
    // MARK: - Activity indicator
    func showActivityIndicator() {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        loginButton.hidden = true
    }
    
    func hideActivityIndicator() {
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        loginButton.hidden = false
    }
    
    // MARK: - Show error alert
    func showAlert(message: NSError) {
        var errMessage = message.localizedDescription
        
        var alert = UIAlertController(title: nil, message: errMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Keyboard Fixes
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}

