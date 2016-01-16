//
//  NewDesiGroupTableViewController.swift
//  Desi
//
//  Created by Matthew Flickner on 5/31/15.
//  Copyright (c) 2015 Desi. All rights reserved.
//

import UIKit
import Parse

class NewDesiGroupTableViewController: UITableViewController {
    /*
    var homeButton : UIBarButtonItem = UIBarButtonItem(title: "LeftButtonTitle", style: UIBarButtonItemStyle.Plain, target: self, action: "")
    
    var logButton : UIBarButtonItem = UIBarButtonItem(title: "RigthButtonTitle", style: UIBarButtonItemStyle.Plain, target: self, action: "")
    
    self.navigationItem.leftBarButtonItem = homeButton
    */

    
    //@IBOutlet weak var newGroupNameTextField: UITextField!
    //@IBOutlet weak var userToAdd: UITextField!
    
    var newGroup: DesiGroup = DesiGroup()
    var myNewUserGroup: DesiUserGroup = DesiUserGroup()
    var newUserGroupTask: DesiUserGroupTask = DesiUserGroupTask()
    var newTask: DesiTask = DesiTask()
    var userGroups: [DesiUserGroup]!
    var usersToAdd = [String]()
    
    //var newGroupUsernames: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem!.enabled = false
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //newGroupUsernames = [String]()
        self.myNewUserGroup.group = self.newGroup
        self.myNewUserGroup.user = DesiUser.currentUser()!
        
        self.newUserGroupTask.userGroup = self.myNewUserGroup
        self.newUserGroupTask.task = self.newTask
        
        

        self.newUserGroupTask.saveInBackgroundWithBlock({
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                print("usergroup saved")
            } else {
                // There was a problem, check error.description
                print("UserGroup Error: \(error)")
            }
        })
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    /*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            newGroupNameTextField.becomeFirstResponder()
        }
    }
    */
    

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0 {
            return 2
        }
        else {
            return self.usersToAdd.count
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("newGroupNameCell", forIndexPath: indexPath) as! TextFieldTableViewCell
                cell.label.text = "Group Name:"
                cell.textField.addTarget(self, action: "checkNewGroupName:", forControlEvents: UIControlEvents.EditingChanged)
                tableView.rowHeight = 44
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("searchForUserCell", forIndexPath: indexPath) as! TextFieldTableViewCell
                tableView.rowHeight = 100
                cell.textField.addTarget(self, action: "enableAdd:", forControlEvents: UIControlEvents.EditingChanged)
                cell.button.enabled = false
                cell.button.addTarget(self, action: "addUserToGroup:", forControlEvents: UIControlEvents.TouchUpInside)
                return cell
            }
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("UserToAddCell", forIndexPath: indexPath) as! DesiFriendTableViewCell
        cell.addButton.tag = indexPath.row
        cell.usernameLabel.text = usersToAdd[indexPath.row]
        cell.addButton.addTarget(self, action: "removeUserFromGroup:", forControlEvents: UIControlEvents.TouchUpInside)
        tableView.rowHeight = 44
        return cell
    }
    
    func isValidUsername(testStr: String) -> Bool {
        let usernameRegEx = "^[a-z0-9_-]{4,16}$"
        let usernameTest = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        return usernameTest.evaluateWithObject(testStr)
    }
    
    @IBAction func enableAdd(sender: UITextField) {
        let indexPath = NSIndexPath(forRow:1, inSection:0)
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! TextFieldTableViewCell
        removeErrorColor(cell.textField)
        if isValidUsername(sender.text!) && self.usersToAdd.count < 10 {
            cell.button.enabled = true
        }
        else {
            cell.button.enabled = false
        }
    }
    
    func setErrorColor(textField: UITextField) {
        let errorColor : UIColor = UIColor.redColor()
        textField.layer.borderColor = errorColor.CGColor
        textField.layer.borderWidth = 1.5
    }
    
    func removeErrorColor(textField: UITextField) {
        textField.layer.borderColor = nil
        textField.layer.borderWidth = 0
    }
    
    @IBAction func addUserToGroup(sender: UIButton){
        print("add pressed")
        let indexPath = NSIndexPath(forRow:1, inSection:0)
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! TextFieldTableViewCell
        if cell.textField.text == DesiUser.currentUser()?.username{
            self.setErrorColor(cell.textField)
            return
        }
        let query = DesiUser.query()
        query!.whereKey("username", equalTo: cell.textField.text!)
        query!.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    // The find succeeded.
                    print("Successfully retrieved \(objects!.count) scores. Swag.")
                    // Do something with the found objects
                    if let objects = objects as? [PFObject] {
                        let users = objects as? [DesiUser]
                        if users!.count == 0 {
                            //set error color
                            self.setErrorColor(cell.textField)
                            sender.enabled = false
                        }
                        else {
                            self.usersToAdd.append(cell.textField.text!)
                            cell.textField.text = ""
                            //limit group size to 10
                            if self.usersToAdd.count > 9 {
                                sender.enabled = false
                            }
                            self.tableView.reloadData()

                        }
                        
                        
                    }
                }
                
            }
            else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        
        
        
    }
    
    @IBAction func removeUserFromGroup(sender: UIButton){
        self.usersToAdd.removeAtIndex(sender.tag)
        self.tableView.reloadData()
    }
    
    @IBAction func checkNewGroupName(sender: UITextField){
        let indexPath = NSIndexPath(forRow:0, inSection:0)
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! TextFieldTableViewCell
        if cell.textField.text == "" {
            self.navigationItem.rightBarButtonItem!.enabled = false
        }
        else {
            self.navigationItem.rightBarButtonItem!.enabled = true
        }
        
    }



    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "createGroup" {
           /*
            self.myNewUserGroup.username = DesiUser.currentUser()!.username
            self.myNewUserGroup.isGroupAdmin = true
            self.myNewUserGroup.groupPoints = 0
            self.myNewUserGroup.groupId = self.newGroup.objectId!
            
            
            let indexPath = NSIndexPath(forRow:0, inSection:0)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! TextFieldTableViewCell
            self.newGroup.groupName = cell.textField.text!
            
            self.newGroup.groupMembers = self.usersToAdd
            self.newGroup.groupMembers.insert(self.myNewUserGroup.username, atIndex: 0)
            self.newGroup.numberOfUsers = self.newGroup.groupMembers.count
            
            self.newTask.taskName = "Designated Driving"
            self.newTask.members = self.newGroup.groupMembers
            self.newTask.desiIndex = 0
            self.newTask.groupId = self.newGroup.objectId!
            self.newTask.theDesi = DesiUser.currentUser()!.username!
            
            
            
            self.newUserGroupTask.userGroup = self.myNewUserGroup
            self.newUserGroupTask.task = self.newTask
            self.newUserGroupTask.isDesi = true
            self.newUserGroupTask.groupId = self.newGroup.objectId!
            self.newUserGroupTask.taskId = self.newTask.objectId!

            //intialTask.theDesi = newUserGroupTask
            
            self.newUserGroupTask.pinInBackgroundWithName("MyUserGroupsTasks")
            self.newUserGroupTask.saveInBackgroundWithBlock({
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    // The object has been saved.
                    print("usergrouptask saved")
                } else {
                    // There was a problem, check error.description
                    print("UserGroupTask Error: \(error)")
                    
                    if error!.code == PFErrorCode.ErrorConnectionFailed.rawValue {
                        self.newUserGroupTask.saveEventually()
                    }
                }
            })
            
            
            //add the user group to the user's list of groups
            DesiUser.currentUser()!.userGroups.append(myNewUserGroup.objectId!)
        
            //store local first then update via network
            /*
            newUserGroupTask.pinInBackgroundWithName("MyUserGroupsTasks")
            newUserGroupTask.saveInBackgroundWithBlock({
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    // The object has been saved.
                    println("usergroup saved")
                } else {
                    // There was a problem, check error.description
                    println("UserGroup Error: \(error)")
                    if error!.code == PFErrorCode.ErrorConnectionFailed.rawValue {
                        self.myNewUserGroup.saveEventually()
                    }
                }
            })*/
            
            for username in self.usersToAdd {
                let newUG = DesiUserGroup()
                newUG.username = username
                newUG.isGroupAdmin = false
                newUG.groupPoints = 0
                newUG.group = self.newGroup
                newUG.groupId = self.newGroup.objectId!
                
                let newUGT = DesiUserGroupTask()
                newUGT.task = self.newTask
                newUGT.userGroup = newUG
                newUGT.isDesi = false
                newUGT.groupId = self.newGroup.objectId!
                newUGT.taskId = self.newTask.objectId!
                
                newUGT.saveInBackgroundWithBlock({
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        // The object has been saved.
                        print("guest usergrouptask saved")
                    } else {
                        // There was a problem, check error.description
                        print("UserGroupTask Error: \(error)")
                        if error!.code == PFErrorCode.ErrorConnectionFailed.rawValue {
                            newUGT.saveEventually()
                        }
                    }
                })
            }
             */

        }

        else {
            //eventually use Parse cloud here later to cascade delete
            self.newUserGroupTask.deleteEventually()
            self.newGroup.deleteEventually()
            self.newTask.deleteEventually()
            self.myNewUserGroup.deleteEventually()
        }
    }



}