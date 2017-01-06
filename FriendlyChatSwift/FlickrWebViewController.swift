//
//  FlickrWebViewController.swift
//  FriendlyChatSwift
//
//  Created by Norris Wise on 8/29/16.
//  Copyright © 2016 Norris Swift Sample Application. All rights reserved.
//

import Foundation
import UIKit


class FlickrWebViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{
    @IBOutlet weak var flickrCollectionView: UICollectionView!
    @IBOutlet weak var flickrPhotoSearchField: UITextField!
    @IBOutlet weak var findButton: UIButton!
//    @IBOutlet weak var flickrPhotoLabel: UILabel!
    
    var chatVC : ChatTableViewController? = nil
//    let cellImgView = CustomFlickrImageCollectionViewCell().flickImgView
    
    
    
    override func viewDidLoad()
    {
        self.flickrCollectionView.delegate = self
        self.flickrCollectionView.dataSource = self
        findButton.addTarget(self, action: #selector(FlickrWebViewController.searchFlickrPhoto), for: UIControlEvents.touchUpInside)
    }
    
    func searchFlickrPhoto()
    {
        let customCell = CustomFlickrImageCollectionViewCell()
        guard flickrPhotoSearchField.text != "" else {
             customCell.flickImgLabel.text = "Please enter search terms"
            return
        }
        
        var flickrPhotos = [NSDictionary]()
        
        getPhotos(buildURL())
        {
            (returnedImages) in
            
             returnedImages
        
        print("Array Of Dictionaries: \(returnedImages)")
            
            self.collectionView(self.flickrCollectionView, numberOfItemsInSection: returnedImages.count)
//            flickrCollectionView.update
            
            
            
            
        
        }
        
        
        
        
    }
    
    func getPhotos(_ url : URL, ImagesReturnedDictAry : @escaping ([NSDictionary]) -> ())
    {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: {
            
            let data = try? Data(contentsOf: url)
            print("data: \(data)\n\n\n")
            
            let JSON =  try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
            
//            print("FULL JSON: \(JSON)")
            let JSONobj = JSON as! [String : Any]
            print("JSON OBJ: \(JSONobj)\n\n")
            let photosObj = JSONobj["photos"] as! [String : Any]
            let photoObjDictAry = photosObj["photo"] as! [[String : AnyObject]]
            print("photoAry: \(photoObjDictAry)\n\n")
            print("JSON OBJ:\(photoObjDictAry[0]["url_o"])")
            
            var returnImagesDictAry = [NSDictionary]()
            var count = 100
            for i in 0..<count
            {
                
                guard (photoObjDictAry[i]["url_o"] != nil) else {print("no image @ photoObjDictAry[\(i)]");count -= 1;
                    continue}
                
                let origPicLink = photoObjDictAry[i]["url_o"]! as! String
                let flickrImgLink = URL(string: origPicLink)!
                let flickrTitle = photoObjDictAry[i]["title"] as! String
                
                
                
                let tempDict: [String: Any] = [
                    "imageTitle" : flickrTitle as String,
                    "imageURL" : flickrImgLink as URL
                ]
                
                returnImagesDictAry.append(tempDict as NSDictionary)

//                let flickrImgData = NSData.init(contentsOfURL: flickrImgLink!)
//                print("flickrImgData: \(flickrImgData!)")
//                let flickrImgRETURNED = UIImage(data: flickrImgData!)!
//                print("\(flickrImgRETURNED)")
                
            }
            
            
            ImagesReturnedDictAry(returnImagesDictAry)
            

        })
    }
    
    
    func buildURL() -> URL
    {
        
        let BASE_URL =  "https://api.flickr.com/services/rest/?"
        let search_param = "method=flickr.photos.search"
        let API_KEY = "api_key=156f13dedb48abf8d03e7e0de43ff0bc"
        let search_string = "text="+flickrPhotoSearchField.text!
        let output_format = "format=json"
        let jsonCallBack_param = "nojsoncallback=1"
        let per_page = "per_page=100"
        let extras = "extras=url_o"
        
     
        
        
        var url = BASE_URL+search_param+"&"+API_KEY+"&"+search_string+"&"+per_page+"&"+output_format+"&"+extras+"&"+jsonCallBack_param
        
        url = url.addingPercentEscapes(using: String.Encoding.utf8)!

        
        let SearchURL = URL.init(string: url)!

        print("...Searching with URL: \(SearchURL)")
        
        return SearchURL
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionFlickrCell", for: indexPath) as! CustomFlickrImageCollectionViewCell
        cell.flickImgLabel.text = "1"
        cell.flickImgView.image = UIImage.init(named: "blackFlower")
        cell.outsideVC = self
     
        return cell
    }
    
    func transporter(_ image : UIImage)
    {
        print("transporter...")

        chatVC!.setSMSBkGround(image)
        self.dismiss(animated: true, completion: nil)
    }
    
    

}
