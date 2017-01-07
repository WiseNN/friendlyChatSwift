//
//  Extensions.swift
//  FriendlyChatSwift
//
//  Created by Norris Wise on 1/6/17.
//  Copyright © 2017 Norris Swift Sample Application. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {

    func saveFileTo(directory: FileManager.SearchPathDirectory, inNewSubDirectory: String, withData: Data,  underFileName: String)
    {
        //get file manager
        let fm = FileManager.default
        do{
            
            //get application support directory
            let parentDirectory = try fm.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            //create custom directory URL inside of application support
            let folderURL = parentDirectory.appendingPathComponent(inNewSubDirectory, isDirectory: true)
            
            
            //check if custom dirctory exists with URL.path
            if !fm.fileExists(atPath: folderURL.path)
            {
                // ... if not, create the the custom directory
                try fm.createDirectory(at: folderURL, withIntermediateDirectories: false, attributes: nil)
            }
            // ...if directory exists, get the document URL
            let fileURL = folderURL.appendingPathComponent(underFileName)
            
            // check if the file exists in this custom directory
            if fm.fileExists(atPath: fileURL.path)
            {
                // ...if file exist, delete it
                try fm.removeItem(at: fileURL)
                
            }
            
            try withData.write(to: fileURL , options: .completeFileProtection)
            
        }catch{
            print("document directory retreival error\(error)")
        }
    }
    
    
    func openFileIn(directory: FileManager.SearchPathDirectory, subDirectory: String?, fileName: String) -> Data?
    {
        //Get file manager
        let fm = FileManager.default
        var data : Data!
        
        do{
            //get parent system directory URL
            let parentDirectory = try fm.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            var folderURL : URL!
            
            if subDirectory != nil
            {
                //append subDirectory URL to parent directory -> URL
                folderURL = parentDirectory.appendingPathComponent(subDirectory!, isDirectory: true)
                
                //Check if file exists at the subDirectory
                guard fm.fileExists(atPath: folderURL.path)  else{
                    // ...if not, throw fatal error, print statememnt
                    print("The Directory \(subDirectory!) does not exist")
                    return nil
                }
            }
            else{
                folderURL = parentDirectory
            }
            
            // ...if so, get location of file under the sub/parent directory
            let fileURL = folderURL.appendingPathComponent(fileName)
            
            //Check to see if file exists
            guard fm.fileExists(atPath: fileURL.path) else{
                
                // ...if not, throw fatal error, and print statement
                print("The File: \(fileName) does not exist in the directory: \(folderURL)")
                return nil
            }
            
            // ...if so, get data from file location and return
            data = try Data.init(contentsOf: fileURL)
            
            
        }
        catch{
            print("Cannot open file \(fileName) error: \(error)")
        }
        return data
    }
    
    
    func quickAnimateViewDisplay(view : UIView, duration : Double)
    {
        self.view.insertSubview(view, at: self.view.subviews.count)
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: {
            view.alpha = 1
            
        }, completion: {_ in
            
            UIView.animate(withDuration: 0.3, delay: duration, options: [.curveEaseOut], animations: {
                view.alpha = 0
            })
            
        })
    }
    
    
    
    func createQuickAlert(text: String) -> UIView
    {
        
        let attributes = [
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName : UIFont.init(name: "Kohinoor Bangla", size: 20)
        ]
        let attrString = NSAttributedString.init(string: text, attributes: attributes)
        
        let fullwidth = self.view.frame.width
        let fullHeight = self.view.frame.height
        let  label = UILabel(frame: CGRect(x: 10, y: 8, width: fullwidth/2, height: 0))
            label.numberOfLines = 0
            label.attributedText = attrString
            label.sizeToFit()
            label.textAlignment = .center
            
        let showFrameView = UIView(frame: CGRect.init(x: fullwidth/4, y: fullHeight/4, width: fullwidth/2+16, height: label.frame.height+16))
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        //always fill the view
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 1
        
        showFrameView.addSubview(blurEffectView)
        showFrameView.addSubview(label)
        

        showFrameView.layer.cornerRadius = showFrameView.frame.width/15
        showFrameView.layer.backgroundColor = UIColor.clear.cgColor
        showFrameView.layer.borderWidth = 0
        showFrameView.layer.borderColor = UIColor.black.cgColor
        showFrameView.layer.masksToBounds = true
        showFrameView.alpha = 0
        //        showFrameView.layer.shadowRadius = 2
        //        showFrameView.layer.shadowColor = UIColor.green.cgColor
        //        showFrameView.layer.shadowOpacity = 1
        
        
        
        
        return showFrameView
        
    }
    
    func useActivityIndicator(onView : UIView) -> UIActivityIndicatorView
    {
        let myActivityIndicator = UIActivityIndicatorView()
        myActivityIndicator.frame = onView.frame
        myActivityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        myActivityIndicator.activityIndicatorViewStyle = .gray
        myActivityIndicator.center = onView.center
        myActivityIndicator.isHidden = false
        myActivityIndicator.hidesWhenStopped = true
        myActivityIndicator.color = UIColor.cyan
//        myActivityIndicator.sizeToFit()

        return myActivityIndicator
    }
}
