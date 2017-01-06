//
//  ViewController.swift
//  FriendlyChatSwift
//
//  Created by Norris Wise on 7/12/16.
//  Copyright © 2016 Norris Swift Sample Application. All rights reserved.
//

import UIKit
import Firebase
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class LoginViewController: UIViewController, UITextFieldDelegate
{
    static let sharedInstance = LoginViewController()
    
    
    
    convenience init()
    {
        self.init()
    }
    

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginAlert: UILabel!
    
    //variables
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    @IBAction func signInMethod(_ sender: AnyObject)
    {
        
        guard MyFireAuth.signedIn == false else{
            
            print("already signed in!")
            return
        }
        
        MyFireAuth.sharedInstance?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!)
        {
            (userObj, error) in

            if(error == nil)
            {
                print("SIGN-IN METHOD")
                MyFireAuth.signedIn = true
                MyFireAuth.user = userObj!
                print("useObj: \(MyFireAuth.user)")
            }
            else
            {
//                let errCode = error!.
                let errMsg =  error!.localizedDescription
                self.loginAlert.adjustsFontSizeToFitWidth = true
                let err = "Error: \(errMsg) "
                self.loginAlert.text = err
                print("ERROR ON SIGN-IN: \(err)")
                return
            }
            
            
            MessageDataModel.sharedInstance.getCurrentUserName({
                (usrName) in
                
                MyFireAuth.currentUserID = String(usrName)
                print("current UserID: \(MyFireAuth.currentUserID)")
                let pageVC = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
                self.navigationController?.setNavigationBarHidden(true, animated: false)
                self.navigationController?.pushViewController(pageVC, animated: true)
            })
            
        }
    }
    
    
    
    @IBAction func signUpMethod(_ sender: AnyObject)
    {
        //get initialVC reference to update labels
        
        
        // Sign Up with credentials.
        
        self.loginAlert.adjustsFontSizeToFitWidth = true
        
        
        //Check if username textfield is empty
        guard usernameTextField.text! != "" else{
            loginAlert.adjustsFontSizeToFitWidth = true
            print("Error: please enter a username")
            self.loginAlert.text! = "please enter a username"
            
            return
        }
        
        //Check email textfield is empty
        guard emailTextField.text! != "" else{
            loginAlert.adjustsFontSizeToFitWidth = true
            print("Error: please enter an email address")
            self.loginAlert.text! = "please enter an email address"
            return
        }
        
        //Check password textfield is empty
        guard passwordTextField.text! != "" else{
            loginAlert.adjustsFontSizeToFitWidth = true
            print("Error: please enter a password")
            self.loginAlert.text! = "please enter a password"
            return
        }
        //Check if username is valid (Fix Regex) 
//        guard validateUsername(usernameTextField.text!) else{
//            print("Error: Sorry usernames cannot be empty or contain: . , # , $ , [ , or ] ")
//            loginAlert.text = "Sorry usernames cannot be empty or contain: . , # , $ , [ , or ] "
//            return
//        }
        
        //Check if username length is sufficient
        guard usernameTextField.text?.characters.count > 1 else{
            print("Error: Sorry usernames must be longer than one character")
            loginAlert.text = "Sorry usernames must be longer than one character"
            return
        }
        
        //Check if email address is valid
        guard  validateEmail(emailTextField.text!) else{
            print("Error: not a valid email address")
            self.loginAlert.text = "not a valid email address"
            return
        }
        
        //Check if password length is sufficient
        guard passwordTextField.text?.characters.count > 6 else{
            print("Error: Sorry, passwords have to be longer than 6 characters")
            self.loginAlert.text = "Sorry, passwords have to be longer than 6 characters"
            return
        }
        
        MyFireAuth.sharedInstance?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            
            (user, error) in
            self.passwordTextField.text = ""
            if let error = error
            {
                print("sign-up error: \(error.localizedDescription)")
                self.loginAlert.text = error.localizedDescription
                return
            }
            if (user?.email != self.emailTextField.text!)
            {
                print("IMPORTANT ERROR: user cannot sign-up, report to system administrator")
                self.loginAlert.text = "please try to sign-up again, there may be an error with the system \n Thank You!"
                return
            }
            
            self.createUserPathSignUpHelper(user!, displayName: self.usernameTextField.text!)
            self.emailTextField.text = ""
            self.usernameTextField.text = ""
            
//           let vc = self.navigationController?.viewControllers[0] as! LoginViewController

            print("Successful sign-up")
            
            
//            vc.loginAlert.text = "\(MyFireAuth.currentUserID) has been signed up!"
            
            self.dismiss(animated: true, completion: nil)
            
        }

      
        
    }
    
    @IBAction func cancelSignUpMethod(_ sender: AnyObject)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    

    func signOutMethod()
    {
       
        do {
            
            try MyFireAuth.sharedInstance?.signOut()
            MyFireAuth.signedIn = false
            loginAlert.text  = "Signed Out"
        }
        catch let signOutError as NSError {
            
            print ("Error signing out: \(signOutError.localizedDescription)")
            loginAlert.text = signOutError.localizedDescription
        }
    }
    @IBAction func callSignOutMethod(_ sender: AnyObject)
    {
        signOutMethod()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    //Helper methods, remember to change param back to: FIRUser
    func  createUserPathSignUpHelper(_ userSigningUp : FIRUser, displayName : String )
    {
        
    let newUserPathForPrivateChat : [String : AnyObject ]
        
        = ["privateChat/_\(displayName)/" : 1 as AnyObject
            ,"users/\(userSigningUp.uid)/" : displayName as AnyObject]

        FIRDatabase.database().reference().updateChildValues(newUserPathForPrivateChat, withCompletionBlock: { (err, ref) in
            
            guard err == nil else{
                print("ERROR UPDATING NEW USER PATH: \(err?.localizedDescription)")
                return
            }
            
            print("-----------------------------------------")
            print("UPDATED-- AFTER CREATION OF NEW USER PATH... ")
            print("-----------------------------------------")
        })
    }
    
    func validateUsername(_ username : String) -> Bool
    {
        let nameRegex = "[.#$\\[\\]]"
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: username)
    }

    
    func validateEmail(_ candidate: String) -> Bool
    {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    



}

