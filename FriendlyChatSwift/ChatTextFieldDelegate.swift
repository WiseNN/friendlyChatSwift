//
//  ChatTextFieldDelegate.swift
//  FriendlyChatSwift
//
//  Created by Norris Wise on 7/18/16.
//  Copyright © 2016 Norris Swift Sample Application. All rights reserved.
//

import Foundation
import UIKit
class ChatTextFieldDelegate : NSObject, UITextFieldDelegate
{
//    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
//    {
//            return false
//    }
    
//    func textFieldDidBeginEditing(textField: UITextField)
//    {
//        
//    }
    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
//    {
//        return false
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
}
