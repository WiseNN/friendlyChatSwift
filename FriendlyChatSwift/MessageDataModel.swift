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
    
	let dbRef = Database.database().reference()
    
    
    fileprivate override init() {}
    
    func searchForRecipeintHelper(_ recipeint : String , completion : @escaping ( _ valueResults : Int?)->())
    {
        
        //        WRITE CUSTOM IMPLEMENTATION FOR SEARCH FOR RECIPEINT HELPER!!
        /* ---------------------------------------------------------------------- */
        
        
            let privateChatKey = "privateChat"
        
		Database.database().reference().child(privateChatKey).observeSingleEvent(of: .value, with: { (snapshot) in
//                print("searchForRecipeintHelper: \(snapshot.value!)")
        
        
                let valueFromSnap = (snapshot.value! as AnyObject).value(forKey: "_\(recipeint)") as? Int
                
               
//            print("valuevalueFromSnapShotInHelper: \(valueFromSnap)")
            completion(valueFromSnap)
            

            
            })
        
            
        
        
    }
    
    func loadDbMessages(_ completionClosure: @escaping (_ result: [String:String])-> ())
    {
        let privateChat = "privateChat"
        let messages = "messages"
        let path = privateChat+"/"+MyFireAuth.currentUserID+"/"+MyFireAuth.recipeintID+"/"+messages
		let dbMsgRef = Database.database().reference().child(path)
        
        let handle =  dbMsgRef.queryOrderedByKey().observe(.childAdded, with: {
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
            
            completionClosure(data)
            
            
            
            
            
        })
        
    }
    
    func getCurrentUserName(_ completion : @escaping (_ userId : String)->())
    {
        
		Database.database().reference().child("users").observeSingleEvent(of: .value, with: {
            (snapshot) in
            
            
            
			let  getUserId = (snapshot.value! as AnyObject).value(forKey: (MyFireAuth.sharedInstance.currentUser?.uid)!) as! String
            
            print("getUserId: \(getUserId)")
            completion(getUserId)
            
        })
        
        func searchingForRecipeint(_ name:String, completion:(_ bool:Bool)->())
        {
            
        }
        
    }
    
    
    

    
    
    
    
    
    
    
}
