//
//  SearchRecipeintViewController.swift
//  FriendlyChatSwift
//
//  Created by Norris Wise on 7/16/16.
//  Copyright © 2016 Norris Swift Sample Application. All rights reserved.
//

import UIKit
import Firebase
class SearchRecipeintViewController : UIViewController, UITextFieldDelegate
{
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var resultsLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadGestures()
        searchTextField.delegate = self
        greetings()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        
        hideNav()
    }
    
    
    func hideNav()
    {
//        self.navigationController?.navigationItem.title = "Search"
        self.navigationController?.viewControllers[1].navigationItem.title = "Search"
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    func greetings()
    {
        MessageDataModel.sharedInstance.getCurrentUserName({
            (usrName) in
            self.resultsLabel.text = "Hey \(usrName)"
        })
    }
    
    func loadGestures()
    {
       //When the user taps 2 times, the sign out menu when slide in (down) form the top of the screen
        //We have not figured out how to implement this feature yet
        
        let searchScreenTaps =  UITapGestureRecognizer.init(target: self, action: #selector(SearchRecipeintViewController.adjustForSignOut))
        searchScreenTaps.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(searchScreenTaps)
    }
    
    func adjustForSignOut()
    {
       print("sign-out now!")
    }
    
    @IBAction func chatButtonMethod(sender: AnyObject)
    {
        print("button pressed")
        
        //Check if textfield is empty
        guard let nsName : NSString = searchTextField.text where searchTextField.text != "" else{
            searchTextField.adjustsFontSizeToFitWidth = true
            resultsLabel.text! = "please enter a user name"
            return
        }
        
//        //Validate username (Fix Regex) //*** add the white space regex as well ***
//        guard validateUsername(name) else{
//            print("Not a valid username")
//            resultsLabel.text = "That is not a valid username"
//            return
//        }
        
   
        //Creates the conversation path @ "/privateChat/currentUser/recipeintUser"
        

        //        //Checks if the user is in the database, prints a message onscreen if not
        
        
        var resultLabelText = ""
        var isRecipeintValid = false
        
        let name = Utilities().removeWhiteSpace(nsName)
        self.searchForRecipeint(name)
        {
            (value) in
            
            
            
                switch value
                {
                
                case 0 :
                    resultLabelText = "User Cant recieve messages"
                    isRecipeintValid = false
                    break
                case 1 :
                    resultLabelText = "User Found!"
                    isRecipeintValid = true
                    break
                case 2 :
                    resultLabelText = "No user with that username"
                    isRecipeintValid = false
                    break
                
                default :
                    print("default switch case")
                    break
                }
            
            self.resultsLabel.text = resultLabelText
            guard isRecipeintValid else{return}
//            self.createConversationPath(name)
            let chatVC = self.storyboard?.instantiateViewControllerWithIdentifier("ChatTableViewController") as! ChatTableViewController
            
            MyFireAuth.recipeintID = name

            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    
    }
    
    //function to validate the email address, returns true if validated
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
    }
    
    
    
    //search method for recipeint, returns true if username belongs to a user
    func searchForRecipeint(recipeint: String, completion : (value : Int)->())
    {
            MessageDataModel.sharedInstance.searchForRecipeintHelper(recipeint){ (valueFromHelper) in
                
                guard let localvalue = valueFromHelper else {
                    print("No value has been returned. Look in class: MessageDataModel method:searchForRecipeintHelper Lines: 40-53")
                        let errValue = 2
                    completion(value: errValue)
                    return
                }
                 completion(value: localvalue  )
            }
    }
    
    
    
    func createConversationPath(usrName : String)
    {
        
        MessageDataModel.sharedInstance.getCurrentUserName({
        (currentUserName) in
            
            let currentUserSubPath = "\(currentUserName)"
            
            
            let ref = FIRDatabase.database().reference().child("privateChat")
            
            
                    let usrRecipeintMsgPath : [String : Bool] = [
                    "/\(currentUserSubPath) /\(usrName)" : true
                ]
                
            
            ref.updateChildValues(usrRecipeintMsgPath, withCompletionBlock: {
            (err, ref) in
                
                if err != nil
                {
                    print(err?.localizedDescription)
                    return
                }
                
                ref.observeSingleEventOfType(.Value, withBlock: {
                    (snap) in
                    
                    print("NEW REF SNAP: \(snap.value)")
                })
            })
                print("new conversation path has been created")
            
            })
        
    }
    
    func validateUsername(username : String) -> Bool
    {
        let nameRegex = "[.#$\\[\\]]"
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluateWithObject(username)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    
    
}
