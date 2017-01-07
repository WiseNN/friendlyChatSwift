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
    @IBOutlet weak var signOutButton: UIButton!
    
    
    
    var appDel : AppDelegate!
    
    lazy var welcomeMessage = {
        {
         return "Hey \(MyFireAuth.currentUserID)"
        }
    }
    
    var originalY : CGFloat!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.appDel =  UIApplication.shared.delegate as! AppDelegate!
    
     
        self.searchTextField.delegate = self
        
        let panGesture = UIPanGestureRecognizer()
        panGesture.minimumNumberOfTouches = 1
        panGesture.addTarget(self, action: #selector(SearchRecipeintViewController.panGestureHandler))
        
        self.view.addGestureRecognizer(panGesture)
        
        self.signOutButton.addTarget(self, action: #selector(SearchRecipeintViewController.signOutButtonHandler), for: .touchUpInside)
        
        self.loadGestures()
        self.greetings()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.hideNav()
        self.hideSignOutButton()
    }
    
    func hideSignOutButton()
    {
        self.signOutButton.transform = CGAffineTransform.init(translationX: 0, y: -self.signOutButton.frame.height)
        
        self.originalY = self.view.frame.minY
    }
    
    func greetings()
    {
        self.resultsLabel.text = self.welcomeMessage()()
    }
    
    func signOutButtonHandler()
    {
        
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginVC.signOutMethod(vc: self)
        
        //scroll view down, delay 3.0 for sign-out flash view
        UIView.animate(withDuration: 0.3, delay: 0.7, options: [], animations: {
            
            self.view.transform = CGAffineTransform.identity
        }, completion: {
            
            done in
            guard done else{return}

                    self.navigationController?.popViewController(animated: true)
        })
       
        
        

        
        
        
        
        
    }
    
    func panGestureHandler(gesture : UIPanGestureRecognizer)
    {
        let subViewHeight : CGFloat! = self.signOutButton.frame.height
        
        print("translation in child: \(gesture.translation(in: self.view))")
        
        print("translation velocity self.view: \(gesture.velocity(in: self.view))")
        
        
        if gesture.state == .began && gesture.translation(in: self.view).y < 0 && gesture.translation(in: self.view).x < 1 && self.signOutButton.bounds.maxY > self.originalY
        {
            self.view.tag = 1
            
            //scroll up
            UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                
                self.view.transform = CGAffineTransform.identity
                }, completion: {
                    done in
                    //send button to back
                    self.view.sendSubview(toBack: self.signOutButton)
            })
                
        }
        else if gesture.state == .changed && gesture.translation(in: self.view).y > 0 && -subViewHeight <= self.view.frame.minY
        {
            self.view.tag = 0
            
            //scroll view down
            UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                
                self.view.transform = CGAffineTransform.init(translationX: 0, y: subViewHeight)
            }, completion: {
                
                done in
                /*
                //add button to view hierarchy
                self.view.addSubview(self.signOutButton)
                
                //enable button
                self.signOutButton.isUserInteractionEnabled = true
 
                 */
            })
        }
    }
    
   
    
    func hideNav()
    {
//        self.navigationController?.navigationItem.title = "Search"
        
        self.navigationController?.viewControllers[1].navigationItem.title = "Search"
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
    
    func animateTextChange(newText : String)
    {
        //fade the label out
        UIView.animate(withDuration: 0.2, animations: {
            self.resultsLabel.alpha = CGFloat.init(0)
        }, completion: { done in
        
            //fade label back in, change text
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            
                self.resultsLabel.alpha = CGFloat.init(1)
                self.resultsLabel.text = newText
            }, completion: { done in
            
                //fade label back out
                UIView.animate(withDuration: 0.3, delay: 0.75 , animations: {
                self.resultsLabel.alpha = CGFloat.init(0)
                }, completion: { done in
                
                    //fade label back in with new text
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                        self.resultsLabel.alpha = CGFloat.init(1)
                        self.resultsLabel.text = self.welcomeMessage()()
                    })
                
                })
            })
        })
    }
    
    @IBAction func chatButtonMethod(_ sender: AnyObject)
    {
        print("button pressed")
        
        //Check if textfield is empty
        guard let nsName : NSString = searchTextField.text as NSString?, searchTextField.text != "" else{
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
            value in
            
            
            
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
            
            
            self.animateTextChange(newText: resultLabelText)
            guard isRecipeintValid else{return}
//            self.createConversationPath(name)
            
            let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatTableViewController") as! ChatTableViewController
            
            chatVC.logoutButton = self.signOutButton
            MyFireAuth.recipeintID = name

            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    
    }
    
    //function to validate the email address, returns true if validated
    func validateEmail(_ candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    
    
    //search method for recipeint, returns true if username belongs to a user
    func searchForRecipeint(_ recipeint: String, completion : @escaping (_ value : Int)->())
    {
            MessageDataModel.sharedInstance.searchForRecipeintHelper(recipeint){ (valueFromHelper) in
                
                guard let localvalue = valueFromHelper else {
                    print("No value has been returned. Look in class: MessageDataModel method:searchForRecipeintHelper Lines: 40-53")
                        let errValue = 2
                    completion(errValue)
                    return
                }
                 completion(localvalue)
            }
    }
    
    
    
    func createConversationPath(_ usrName : String)
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
                
                ref.observeSingleEvent(of: .value, with: {
                    (snap) in
                    
                    print("NEW REF SNAP: \(snap.value)")
                })
            })
                print("new conversation path has been created")
            
            })
        
    }
    
    func validateUsername(_ username : String) -> Bool
    {
        let nameRegex = "[.#$\\[\\]]"
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: username)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    
    
}


