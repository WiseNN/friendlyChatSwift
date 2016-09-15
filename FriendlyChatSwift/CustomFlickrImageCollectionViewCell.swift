//
//  CustomFlickrImageCollectionViewCell.swift
//  FriendlyChatSwift
//
//  Created by Norris Wise on 8/30/16.
//  Copyright © 2016 Norris Swift Sample Application. All rights reserved.
//

import Foundation
import UIKit

class CustomFlickrImageCollectionViewCell : UICollectionViewCell
{
    
    @IBOutlet weak var flickImgView: UIImageView!
    @IBOutlet weak var flickImgLabel: UILabel!
    var outsideVC : FlickrWebViewController?
    
    override func layoutSubviews()
    {
        print("subViews...")
        flickImgView.userInteractionEnabled = true
        let DoubleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(CustomFlickrImageCollectionViewCell.transport))
        DoubleTapGesture.numberOfTapsRequired = 2
            flickImgView.addGestureRecognizer(DoubleTapGesture)
    }
    
    func transport()
    {
        
        
        let currentImg = flickImgView.image
        outsideVC!.transporter(currentImg!)
        
        
    }
}

