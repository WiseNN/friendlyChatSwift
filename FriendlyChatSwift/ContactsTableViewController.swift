//
//  SelectRecipeintViewController.swift
//  FriendlyChatSwift
//
//  Created by Norris Wise on 7/15/16.
//  Copyright © 2016 Norris Swift Sample Application. All rights reserved.
//

import Foundation
import UIKit
class ContactsTableViewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet var contactsTableView: UITableView!
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = contactsTableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        
        return cell
    }
}
