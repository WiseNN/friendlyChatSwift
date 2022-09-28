//
//  Authentication.swift
//  FriendlyChatSwift
//
//  Created by Norris Wise on 7/16/16.
//  Copyright © 2016 Norris Swift Sample Application. All rights reserved.
//

import Foundation
import FirebaseAuth

class MyFireAuth : Auth
{
    static let sharedInstance = MyFireAuth.auth()
    
	static var user = Auth.auth().currentUser
    static var recipeintID = ""
    static var currentUserID = ""
    static var signedIn = false
    static var isRecipeintValid = false
    
    
    
    
}
