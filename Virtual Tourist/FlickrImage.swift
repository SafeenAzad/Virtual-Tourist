//
//  FlickrImage.swift
//  Virtual Tourist
//
//  Created by Safeen Azad on 9/9/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import UIKit
import CoreData

class FlickrImage {
    
    let id:String
    let secret:String
    let server:String
    let farm:Int
    
    init(id: String, secret: String, server: String, farm: Int) {
        
        self.id = id
        self.secret = secret
        self.server = server
        self.farm = farm
    }
    
    func imageURLString() -> String {
        
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
    }
    
}
