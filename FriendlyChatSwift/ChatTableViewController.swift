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
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let textFieldDelegate = ChatTextFieldDelegate()

    var msgAry = [[String:String]]()
    var recoveredMsg = ""
    var didSessionTimeOut = false
    var handler :UInt = 0
    var autoScroll = false
    static var rowHeight : CGFloat = 0
    
    
    
    override func viewDidLoad()
    {
        
        msgTableView.delegate = self
        msgTableView.dataSource = self
        msgTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        
        
        postMesgTxtField.delegate = textFieldDelegate
            self.msgTableView.scrollsToTop = false
            self.loadMsgsFromMessageDataModel()
        
        
//        self.msgTableView.backgroundView = UIImageView(image: UIImage(named: "greenBubble"))

    }
    override func viewWillAppear(animated: Bool)
    {
        showNav()
        
    }
    
    func showNav()
    {
        let title = "\(MyFireAuth.recipeintID)"
        let navTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        navTitleLabel.backgroundColor = UIColor.clearColor()
        navTitleLabel.text = title
        navTitleLabel.adjustsFontSizeToFitWidth = true
        navTitleLabel.sizeToFit()
        
        self.navigationItem.titleView = navTitleLabel
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Search", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ChatTableViewController.leftBarButtonHandler))
        
        let img = UIImage.init(named: "flickr-3")
        
        let imgV = UIImageView(frame: CGRect.init(x: 0, y: -4, width: 30, height: 30))
        imgV.image = img
        
        let rightButton = UIButton.init()
        rightButton.addTarget(self, action: #selector(ChatTableViewController.seeFlickrWebViewer), forControlEvents: UIControlEvents.TouchUpInside)
        rightButton.addSubview(imgV)
        rightButton.sizeToFit()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightButton)
        
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    func setSMSBkGround(SMSBkGroundImg : UIImage)
    {
        
        self.msgTableView.backgroundView = UIImageView(image: SMSBkGroundImg)
    }
    
    
    func seeFlickrWebViewer()
    {
        print("Flickr image...")
        let flickrVC = storyboard?.instantiateViewControllerWithIdentifier("FlickrWebViewController") as! FlickrWebViewController
        
        flickrVC.chatVC = self
        self.presentViewController(flickrVC, animated: true, completion: nil)
    
    }
    
    func leftBarButtonHandler()
    {
        self.navigationController?.popViewControllerAnimated(true)
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
            let Path  : [NSIndexPath]? = [NSIndexPath(forRow: self.msgAry.count-1, inSection: 0)]
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
        guard var message = postMesgTxtField.text where postMesgTxtField.text! != "" else{
            print("no message in text field")
            return
        }
        postMesgTxtField.text = ""
        message = Utilities().removeLeadingTrailingWhiteSpace(NSString(string: message))
        let index1 = NSDate().description.startIndex.advancedBy(10)
        let date = NSDate().description.substringToIndex(index1)
        let rangeBegin = NSDate().description.startIndex.advancedBy(11)
        let rangeEnd = NSDate().description.startIndex.advancedBy(18)
        let range = (rangeBegin...rangeEnd)
        let time = NSDate().description.substringWithRange(range)
        
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
        loginVC.signOutMethod()
        
        if let msg = postMesgTxtField.text{
            recoveredMsg = msg
            loginAlertMsg = "Message Saved. \n \(timedOutMsg)"
        }
        else{
            loginAlertMsg = timedOutMsg
        }
        
        
        loginVC.loginAlert.text = loginAlertMsg
        self.navigationController?.popToRootViewControllerAnimated(true);
    }
    func signOut()
    {
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        LoginViewController.sharedInstance.signOutMethod()
        self.navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
    

   // Table Configuration-------------------------------------------------
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.msgAry.count
    }
    
    func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        
        let msg = msgAry[indexPath.row]["message"]!
        let sender = msgAry[indexPath.row]["sender"]!
        let bubble = BubbleFactory(message: msg, sender:sender , table: tableView)
        let bgColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        bubble.backgroundColor = bgColor
        bubble.selectedBackgroundView = .None
        bubble.userInteractionEnabled = false
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
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        self.scrollToBottomOfTable()
        
    }
    
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView)
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
    
    override func viewDidAppear(animated: Bool)
    {

        self.autoScroll = true

    }
    

    
    
}