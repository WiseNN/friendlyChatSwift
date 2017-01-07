//
//  ChatViewController.swift
//  FriendlyChatSwift
//
//  Created by Norris Wise on 7/13/16.
//  Copyright © 2016 Norris Swift Sample Application. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ChatTableViewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    
    @IBOutlet weak var msgTableView: UITableView!
    @IBOutlet weak var postMesgTxtField: UITextField!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let textFieldDelegate = ChatTextFieldDelegate()

    var msgAry = [[String:String]]()
    var recoveredMsg = ""
    var didSessionTimeOut = false
    var handler :UInt = 0
    var autoScroll = false
    var logoutButton : UIButton!
    
    static var rowHeight : CGFloat = 0
    
    
    
    override func viewDidLoad()
    {
        self.logoutButton.addTarget(self, action: #selector(ChatTableViewController.signOutButtonHandler), for: .touchUpInside)
        msgTableView.delegate = self
        msgTableView.dataSource = self
        msgTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        postMesgTxtField.delegate = textFieldDelegate
            self.msgTableView.scrollsToTop = false
            self.loadMsgsFromMessageDataModel()
        
        self.msgTableView.backgroundView = UIImageView(image: loadBackgroundImage())
        self.msgTableView.backgroundView?.contentMode = .scaleAspectFill
        
        
        
        
//        self.msgTableView.backgroundView = UIImageView(image: UIImage(named: "greenBubble"))

    }
    override func viewWillAppear(_ animated: Bool)
    {
        showNav()
    }
    
    func loadBackgroundImage() -> UIImage?
    {
        let imageData = self.openFileIn(directory: .applicationSupportDirectory, subDirectory: "photos", fileName: "backgroundImage")
        guard imageData != nil else{return nil}
        let image = UIImage.init(data: imageData!)
        return image
    }
    
    func showNav()
    {
        let title = "\(MyFireAuth.recipeintID)"
        let navTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        navTitleLabel.backgroundColor = UIColor.clear
        navTitleLabel.text = title
        navTitleLabel.adjustsFontSizeToFitWidth = true
        navTitleLabel.sizeToFit()
        
        self.navigationItem.titleView = navTitleLabel
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Search", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ChatTableViewController.leftBarButtonHandler))
        
        let img = UIImage.init(named: "flickr-3")
        
        let imgV = UIImageView(frame: CGRect.init(x: 0, y: -4, width: 30, height: 30))
        imgV.image = img
        
        let rightButton = UIButton.init()
        rightButton.addTarget(self, action: #selector(ChatTableViewController.seeFlickrWebViewer), for: UIControlEvents.touchUpInside)
        rightButton.addSubview(imgV)
        rightButton.sizeToFit()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightButton)
        
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let msgTableNewHeight = self.msgTableView.frame.height - self.navigationController!.navigationBar.frame.height
        self.msgTableView.frame = CGRect.init(x: self.msgTableView.bounds.minX, y: self.navigationController!.navigationBar.frame.height, width: self.msgTableView.frame.width, height: msgTableNewHeight)
        
    }
    
    
    
    func signOutButtonHandler()
    {
        
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginVC.signOutMethod(vc: self)
        
        //scroll view down, delay 0.7 for sign-out flash view
        UIView.animate(withDuration: 0.3, delay: 0.7, options: [], animations: {
            
            self.view.transform = CGAffineTransform.identity
        }, completion: {
            
            done in
            guard done else{return}
            
            _ = self.navigationController?.popViewController(animated: true)
        })
    }
    
    
    
    func setSMSBkGround(_ SMSBkGroundImg : UIImage)
    {
        
        self.msgTableView.backgroundView = UIImageView(image: SMSBkGroundImg)
        self.msgTableView.backgroundView?.contentMode = .scaleAspectFill
        
        DispatchQueue.global(qos: .default).async {
            self.saveBackgroundImage(image: SMSBkGroundImg)
        }
    }
    
    func saveBackgroundImage(image : UIImage)
    {
        let imageData = UIImagePNGRepresentation(image)!
        self.saveFileTo(directory: .applicationSupportDirectory, inNewSubDirectory: "photos", withData: imageData, underFileName: "backgroundImage")
    }
    
    
    func seeFlickrWebViewer()
    {
        print("Flickr image...")
        let flickrVC = storyboard?.instantiateViewController(withIdentifier: "FlickrWebViewController") as! FlickrWebViewController
        
        flickrVC.chatVC = self
        self.present(flickrVC, animated: true, completion: nil)
    
    }
    
    func leftBarButtonHandler()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    func loadMsgsFromMessageDataModel()
    {
        MessageDataModel.sharedInstance.loadDbMessages(){
            (snapshot) in
            self.msgAry.append(snapshot)
//            print("completion: \(snapshot)")
//            print("completion MsgAry: \(self.msgAry)")
            
            
//            self.msgTableView.beginUpdates()
            //create an index path at the last element of msgAry, Section 0
            let Path  : [IndexPath]? = [IndexPath(row: self.msgAry.count-1, section: 0)]
            guard let indexPath = Path else{return}
            self.autoScroll = true
        self.msgTableView.reloadData()
//            self.msgTableView.insertRowsAtIndexPaths(indexPath, withRowAnimation: .Automatic)
//            self.msgTableView.endUpdates()
            

        }
        
        
        
        
        
    }
    
        @IBAction func postMessage()
    {
        let dbRef = MessageDataModel.sharedInstance.dbRef
        let dbConvoRef = dbRef.child("privateChat/\(MyFireAuth.currentUserID)/\(MyFireAuth.recipeintID)")
        let recipeintDBConvoRef = dbRef.child("privateChat/\(MyFireAuth.recipeintID)/\(MyFireAuth.currentUserID)")
        let key = dbConvoRef.childByAutoId().key
        
        guard ((MyFireAuth.sharedInstance?.currentUser) != nil) || MyFireAuth.sharedInstance?.currentUser != MyFireAuth.user
            else{
                sessionTimedOut()
                return
        }
        guard var message = postMesgTxtField.text, postMesgTxtField.text! != "" else{
            print("no message in text field")
            return
        }
        postMesgTxtField.text = ""
        message = Utilities().removeLeadingTrailingWhiteSpace(NSString(string: message))
        
        let index1 = Date().description.characters.index(Date().description.startIndex, offsetBy: 10)
        let date = Date().description.substring(to: index1)
        let rangeBegin = Date().description.index(Date().description.startIndex, offsetBy: 12)
        let rangeEnd = Date().description.index(Date().description.startIndex, offsetBy: 18)
        
        let range = rangeBegin..<rangeEnd
        
        let time = Date().description.substring(with: range)
        
        let post : [String : String] = [
            "sender": MyFireAuth.currentUserID,
            "message": message,
            "date": date,
            "time": time
        ]
        let messagePost : [String : String] = [
            "message" : message,
            "time": time
        ]
        let childUpdatesForUserPosts = [
            "/user-posts/\((MyFireAuth.currentUserID))/\(date)/\(key)/" : messagePost
        ]
        let childUpdatesForPrivateChat = ["/messages/\(key)": post,
                            
        ]
        
        
        print("-----------------------------")
        print("CHILD UPDATE: \(childUpdatesForUserPosts)")
        print("-----------------------------")
        dbRef.updateChildValues(childUpdatesForUserPosts)
        dbConvoRef.updateChildValues(childUpdatesForPrivateChat)
        recipeintDBConvoRef.updateChildValues(childUpdatesForPrivateChat)
        
    }
    
    
    func sessionTimedOut()
    {
        let timedOutMsg = "Your Session has timed out, please login again. \n Thank you"
        var loginAlertMsg = ""
        let loginVC =  self.navigationController?.viewControllers[0] as! LoginViewController
        loginVC.signOutMethod(vc: self)
        
        if let msg = postMesgTxtField.text{
            recoveredMsg = msg
            loginAlertMsg = "Message Saved. \n \(timedOutMsg)"
        }
        else{
            loginAlertMsg = timedOutMsg
        }
        
        
        loginVC.loginAlert.text = loginAlertMsg
        self.navigationController?.popToRootViewController(animated: true);
    }
    func signOut()
    {
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        LoginViewController.sharedInstance.signOutMethod(vc: self)
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    

   // Table Configuration-------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.msgAry.count
    }
    
    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        
        let msg = msgAry[indexPath.row]["message"]!
        let sender = msgAry[indexPath.row]["sender"]!
        let bubble = BubbleFactory(message: msg, sender:sender , table: tableView)
        let bgColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        bubble.backgroundColor = bgColor
        bubble.selectedBackgroundView = .none
        bubble.isUserInteractionEnabled = false
        let container = bubble.generateBubble(msg, sender: sender)
        let height = (container?.frame.height)!
        tableView.rowHeight = height
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        let cH = msgTableView.contentSize.height + 0
        let fH = msgTableView.frame.size.height
        print("Content height before: \(cH)...")
        print("Frame height before: \(fH)...")
        
        
        return bubble
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        self.scrollToBottomOfTable()
        
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        self.autoScroll = false
    }
    func scrollToBottomOfTable()
    {
        
        guard self.autoScroll else {return}
        let contentHeight = self.msgTableView.contentSize.height
        let frameHeight = self.msgTableView.frame.size.height
        
        if contentHeight > frameHeight
        {
            let scrollPoint =  contentHeight - frameHeight
            
            self.msgTableView.setContentOffset(CGPoint(x: 0, y: scrollPoint), animated: true)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {

        self.autoScroll = true

    }
    

    
    
}
