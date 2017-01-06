//
//  PageViewController.swift
//  FriendlyChatSwift
//
//  Created by Norris Wise on 7/16/16.
//  Copyright © 2016 Norris Swift Sample Application. All rights reserved.
//

import UIKit

class PageViewController : UIPageViewController, UIPageViewControllerDataSource
{
    //dummy controller instance
    let vc = ContactsTableViewController()
    var beforePageIndex = 0
    var afterPageIndex = 0
    let totalVC = 2
    
    
    override func viewDidLoad()
    {
        self.dataSource = self
        
        
        self.setViewControllers([getViewControllerAtIndex(0)], direction: .forward, animated: false, completion: nil)
    }

    //Custom method to get data source index and change view controllers
    func getViewControllerAtIndex(_ index : Int) -> UIViewController
    {
        var currentVC : UIViewController? = nil
        
        switch (index)
        {
        case 0 :
            currentVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchRecipeintViewController") as! SearchRecipeintViewController
        case 1 :
            currentVC = self.storyboard?.instantiateViewController(withIdentifier: "ContactsTableViewController") as! ContactsTableViewController
        default :
            print("Error on selecting view controller...")
        }
//        print("final before: \(self.beforePageIndex)")
//        print("final after: \(self.afterPageIndex)")
        return currentVC!
    }
    
    // DataSource Methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        
        guard self.afterPageIndex != NSNotFound else{return nil}
        
        guard self.afterPageIndex != 1 else{return nil}
        self.afterPageIndex += 1
        print("after: \(self.afterPageIndex)")
        return getViewControllerAtIndex(self.afterPageIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        
        guard self.beforePageIndex != NSNotFound else{return nil}
        guard self.beforePageIndex > 0 else{return nil}
        self.beforePageIndex -= 1
        print("before: \(self.beforePageIndex)")
        return getViewControllerAtIndex(self.beforePageIndex)
    }
    
}
