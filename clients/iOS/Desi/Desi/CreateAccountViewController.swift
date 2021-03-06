//
//  CreateAccountViewController.swift
//  Desi
//
//  Created by Matthew Flickner on 7/7/15.
//  Copyright (c) 2015 Desi. All rights reserved.
//

import UIKit
import Parse

class CreateAccountViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var password1: UITextField!
    @IBOutlet weak var password2: UITextField!
    @IBOutlet weak var email1: UITextField!
    @IBOutlet weak var email2: UITextField!
    @IBOutlet weak var createButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateAccountViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        //createButton.enabled = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //check the name fields
    func nameCheck(nameField: UITextField) -> Bool {
        if nameField.text != "" {
            return true
        }
        return false
    }
    
    @IBAction func firstNameDone(sender: AnyObject) {
        if nameCheck(self.firstName) {
            setSuccessColor(self.firstName)
            return
        }
        setErrorColor(self.firstName)
    }
    
    @IBAction func lastNameDone(sender: AnyObject) {
        if nameCheck(lastName){
            setSuccessColor(lastName)
            return
        }
        setErrorColor(lastName)
    }
    
    //check the usernames
    func isValidUsername(testStr: String) -> Bool {
        let usernameRegEx = "^[a-z0-9_-]{4,16}$"
        let usernameTest = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        return usernameTest.evaluateWithObject(testStr)
    }
    
    func usernameCheck(usernameField: UITextField) -> Bool{
        usernameField.text = usernameField.text!.lowercaseString
        if isValidUsername(usernameField.text!) {
            setSuccessColor(usernameField)
            return true
        }
        else {
            setErrorColor(usernameField)
            return false
        }
    }
    
    @IBAction func usernameDone(sender : AnyObject) {
        if (isValidUsername(self.username.text!) && usernameCheck(self.username)){
            setSuccessColor(self.username)
            return
        }
        setErrorColor(username)
    }
    
    // password functions
    func isValidPassword(testStr: String) -> Bool {
        let passwordRegEx = "^[a-z0-9_-]{6,256}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluateWithObject(testStr)
    }
    
    
    func passwordsMatch() -> Bool{
        print("passwords check")
        if password1.text == password2.text {
            return true
        }
        return false
    }
    
    @IBAction func password1Done(sender: AnyObject) {
        if isValidPassword(password1.text!) {
            if(password2.text != ""){
                if passwordsMatch(){
                    setSuccessColor(password2)
                }
                else {
                    setErrorColor(password2)
                    setErrorColor(password1)
                    return
                }
            }
            setSuccessColor(password1)
            return
        }
        setErrorColor(password1)
        
    }
    
    @IBAction func password2Done(sender: AnyObject) {
        if isValidPassword(password2.text!) {
            if(password1.text != ""){
                if passwordsMatch(){
                    setSuccessColor(password1)
                }
                else {
                    setErrorColor(password2)
                    setErrorColor(password1)
                    return
                }
            }
            setSuccessColor(password2)
            return
        }
        setErrorColor(password2)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        print("email valid ran")
        return emailTest.evaluateWithObject(testStr)
    }
    
    func emailCheck(email: UITextField) -> Bool{
        if isValidEmail(email.text!){
            print("email good")
            setSuccessColor(email)
            return true
        }
        setErrorColor(email)
        print("email bad")
        return false
        
    }
    
    func emailsMatch() -> Bool{
        if email1.text == email2.text {
            setSuccessColor(email1)
            setSuccessColor(email2)
            print("emails match")
            return true
        }
        setErrorColor(email1)
        setErrorColor(email2)
        print("emails match")
        return false
    }
    
    
    
    @IBAction func email1Done(sender: AnyObject) {
        print("email1 done")
        emailCheck(email1)
        if(email2.text != ""){
            emailsMatch()
        }
        //set the array in these functions
        
    }
    
    @IBAction func email2Done(sender: AnyObject) {
        print("email2 done")
        emailCheck(email2)
        if(email1.text != ""){
            emailsMatch()
        }
    }
    
    
    
    func createAccount(){
        let newUser = DesiUser()
        newUser.username = self.email1.text
        newUser.password = self.password1.text
        newUser.email = self.email1.text
        newUser.firstName = self.firstName.text!
        newUser.lastName = self.lastName.text!
        //newUser.userGroups = [String]()
        newUser.desiScore = 0
        newUser.signUpInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                print("success")
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("createAccountSegue", sender: self)
                }
            }
            else {
                print("\(error)")
                // Show the errorString somewhere and let the user try again.
            }
        }
    }
    
    @IBAction func createTapped(sender : AnyObject) {
        print("created tapped")
        createAccount()
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "createAccountSegue") {
            let split = segue.destinationViewController as! UISplitViewController
            let nav = split.viewControllers.last as! DesiNaviagtionController
            let homeView = nav.topViewController as! DesiHomeViewController
            homeView.myUserGroups = [DesiUserGroup]()
        }

    }



}
