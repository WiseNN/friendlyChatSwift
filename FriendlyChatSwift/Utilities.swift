//
//  Utilities.swift
//  FriendlyChatSwift
//
//  Created by Norris Wise on 7/31/16.
//  Copyright © 2016 Norris Swift Sample Application. All rights reserved.
//

import Foundation

class Utilities
{
 
    func removeWhiteSpace(nsName : NSString)->String
    {
        var localNSname = ""
        var accessd = false
        for i in 0...nsName.length-1
        {
            guard nsName.characterAtIndex(i)  == 32 else{continue}
            accessd = true
            localNSname = nsName.substringToIndex(i)
        }
        
        if(!accessd)
        {
            localNSname = nsName as String
        }
        
        return localNSname
    }
    
    func removeLeadingTrailingWhiteSpace(nsName : NSString) -> String
    {
        var localNSname = nsName
        
        while localNSname.characterAtIndex(0) == 32
        {
            localNSname = localNSname.substringFromIndex(1)
        }
        
        while localNSname.characterAtIndex(localNSname.length-1) == 32
        {
            localNSname =  localNSname.substringToIndex(localNSname.length-1)
        }

        return String(localNSname)
    }
}
