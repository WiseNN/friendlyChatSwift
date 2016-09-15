//
//  MessageDataModel.swift
//  FriendlyChatSwift
//
//  Created by Norris Wise on 7/14/16.
//  Copyright © 2016 Norris Swift Sample Application. All rights reserved.
//

import Foundation
//import Firebase
import FirebaseDatabase


class MessageDataModel : NSObject
{
    static let sharedInstance = MessageDataModel()
    
    //class object references
    
//    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let dbRef = FIRDatabase.database().reference()
    
    
    private override init() {}
    
    func searchForRecipeintHelper(recipeint : String , completion : ( valueResults : Int?)->())
    {
        
        //        WRITE CUSTOM IMPLEMENTATION FOR SEARCH FOR RECIPEINT HELPER!!
        /* ---------------------------------------------------------------------- */
        
        
            let privateChatKey = "privateChat"
        
            FIRDatabase.database().reference().child(privateChatKey).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
//                print("searchForRecipeintHelper: \(snapshot.value!)")
        
        
                let valueFromSnap = snapshot.value!.valueForKey("_\(recipeint)") as? Int
                
//            print("valuevalueFromSnapShotInHelper: \(valueFromSnap)")
            completion(valueResults: valueFromSnap)
            

            
            })
        
            
        
        
    }
    
    func loadDbMessages(completionClosure: (result: [String:String])-> ())
    {
        let privateChat = "privateChat"
        let messages = "messages"
        let path = privateChat+"/"+MyFireAuth.currentUserID+"/"+MyFireAuth.recipeintID+"/"+messages
        let dbMsgRef = FIRDatabase.database().reference().child(path)
        
        let handle =  dbMsgRef.queryOrderedByKey().observeEventType(.ChildAdded, withBlock: {
            (snapshot) in
            
            
            guard let database =  snapshot.value as? [String:String] else{
                print("Cannot parse data from object: \(snapshot.value)")
                return
            }
            
            guard let sender = database["sender"] else{
                print("Cannot get the sender from key: \"sender\" in object: \(database)")
                return
            }
            guard let message = database["message"] else{
                print("Cannot get message from key: \"message\" in object: \(database)")
                return
            }
           
            
            let data : [String : String] = [
                
                "sender" : sender,
                "message" : message
            ]
            
            completionClosure(result: data)
            
            
            
            
            
        })
        
    }
    
    func getCurrentUserName(completion : (userId : String)->())
    {
        
        FIRDatabase.database().reference().child("users").observeSingleEventOfType(.Value, withBlock: {
            (snapshot) in
            
            
            
            let  getUserId = snapshot.value!.valueForKey((MyFireAuth.sharedInstance?.currentUser?.uid)!) as! String
            
            print("getUserId: \(getUserId)")
            completion(userId: getUserId)
            
        })
        
        func searchingForRecipeint(name:String, completion:(bool:Bool)->())
        {
            
        }
        
    }
    
    
    

    
    
    
    
    
    
    
}