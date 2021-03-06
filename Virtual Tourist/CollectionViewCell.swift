//
//  CollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Safeen Azad on 9/10/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    //Get Photos
    
    func initWithPhoto(_ photo: Photo) {
        
        if photo.imageData != nil {
            
            DispatchQueue.main.async {
                
                self.imageView.image = UIImage(data: photo.imageData! as Data)
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
            
        } else {
            
            downloadImage(photo)
        }
    }
    
    //Download Images
    
    func downloadImage(_ photo: Photo) {
        
       let dataTask = URLSession.shared.dataTask(with: URL(string: photo.imageURL!)!) { (data, response, error) in
            if error == nil {
                
                DispatchQueue.main.async {
                    
                    self.imageView.image = UIImage(data: data! as Data)
                    self.activityIndicator.stopAnimating()
                    self.saveImageDataToCoreData(photo: photo, imageData: data! as NSData)
                }
            }
            
            }
            
            dataTask.resume()
    }
    
    //Save Images
    
    func saveImageDataToCoreData(photo: Photo, imageData: NSData) {
        do {
            photo.imageData = imageData
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let stack = delegate.stack
            try stack.saveContext()
        } catch {
            print("Saving Photo imageData Failed")
        }
    }
    
}
