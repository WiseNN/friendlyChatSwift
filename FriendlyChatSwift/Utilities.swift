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
 
    func removeWhiteSpace(_ nsName : NSString)->String
    {
        var localNSname = ""
        var accessd = false
        for i in 0...nsName.length-1
        {
            guard nsName.character(at: i)  == 32 else{continue}
            accessd = true
            localNSname = nsName.substring(to: i)
        }
        
        if(!accessd)
        {
            localNSname = nsName as String
        }
        
        return localNSname
    }
    
    func removeLeadingTrailingWhiteSpace(_ nsName : NSString) -> String
    {
        var localNSname = nsName
        
        while localNSname.character(at: 0) == 32
        {
            localNSname = localNSname.substring(from: 1) as NSString
        }
        
        while localNSname.character(at: localNSname.length-1) == 32
        {
            localNSname =  localNSname.substring(to: localNSname.length-1) as NSString
        }

        return String(localNSname)
    }
}
