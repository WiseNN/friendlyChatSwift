//
//  PrimaryUserBubble.swift
//  FriendlyChatSwift
//
//  Created by Norris Wise on 7/29/16.
//  Copyright © 2016 Norris Swift Sample Application. All rights reserved.
//

import Foundation
import UIKit

class BubbleFactory : UITableViewCell
{
    var myMsg = ""
     var sender = ""
    var bubbleContainerFrame : CGRect?
    var myTable : UITableView!
    
    
    convenience init(message : String, sender : String, table : UITableView)
    {
        self.init()
        self.sender = sender
        
        myMsg = message
        myTable = table
        
        
    }
    
    override func layoutSubviews()
    {
        guard let addView = generateBubble(nil,sender: nil) else{return}
        self.contentView.addSubview(addView)
    }
    
    func generateBubble(_ message : String?, sender : String?) -> UIImageView?
    {
        
        var view = UIImageView.init()
        
        if message != nil
        {
            self.myMsg = message!
        }
        if sender != nil
        {
            self.sender = sender!
        }
        
        if self.sender == MyFireAuth.currentUserID
        {
            view =  userBubble()
        }
        else{
            view = recipientBubble()
        }
//        
//        print("view frame: \(view.frame)")
        
//        ChatTableViewController.rowHeight = view.frame.height
//        myTable.rowHeight = view.frame.height
        print("View : \(view.frame)")
        
        return view
    }
    
    func userBubble() -> UIImageView
    {
//        let message = createMessage()
        
        
        //create message and message frame
     
        
        let msgPosX = 8
        let msgPosY = 3
        let myLabel = UILabel(frame: CGRect(x: msgPosX, y: msgPosY, width: 140, height: 10))
        myLabel.numberOfLines = 0
        myLabel.text = myMsg
        myLabel.sizeToFit()
        let message = myLabel
        let bubblePosX = self.frame.width - message.frame.width
        
        let insets = UIEdgeInsets(top: 15, left: 20, bottom: 25, right: 25)
        let bubbleImg = UIImage(named: "greenBubble")?.resizableImage(withCapInsets: insets)
     
        let padding : CGFloat = 14.0
        let bubbleImgFrame = UIImageView(frame: CGRect(x: 0, y: 0, width: message.frame.width+CGFloat(msgPosX)+padding+8, height: message.frame.height+padding))
        bubbleImgFrame.image = bubbleImg
        
        let contaienrPosX = self.frame.width - bubbleImgFrame.frame.width
        let containerFrame = UIImageView(frame: CGRect(x: contaienrPosX, y: 0, width: bubbleImgFrame.frame.width, height: bubbleImgFrame.frame.height+padding))
        
        containerFrame.addSubview(bubbleImgFrame)
        containerFrame.addSubview(message)
        
        bubbleContainerFrame = containerFrame.frame
        return containerFrame
    }
    
    func recipientBubble() -> UIImageView
    {
//        let message = createMessage()
        
        //create message and message frame
        let msgPosX = 15
        let msgPosY = 4
        let myLabel = UILabel(frame: CGRect(x: msgPosX, y: msgPosY, width: 140, height: 10))
        myLabel.numberOfLines = 0
        myLabel.text = myMsg
        myLabel.sizeToFit()
        let message = myLabel
        let bubblePosX = self.frame.width - message.frame.width
        
        let insets = UIEdgeInsets(top: 15, left: 20, bottom: 25, right: 20)
        let bubbleImg = UIImage(named: "greyBubble")?.resizableImage(withCapInsets: insets)
        
        let padding : CGFloat = 14.0
        let bubbleImgFrame = UIImageView(frame: CGRect(x: 0, y: 0, width: message.frame.width+CGFloat(msgPosX)+padding+8, height: message.frame.height+padding))
        bubbleImgFrame.image = bubbleImg
        
        let contaienrPosX = self.frame.width - bubbleImgFrame.frame.width
        let containerFrame = UIImageView(frame: CGRect(x: 0, y: 0, width: bubbleImgFrame.frame.width, height: bubbleImgFrame.frame.height+padding))
        
        containerFrame.addSubview(bubbleImgFrame)
        containerFrame.addSubview(message)
        
        bubbleContainerFrame = containerFrame.frame
        return containerFrame
        
    }
}
