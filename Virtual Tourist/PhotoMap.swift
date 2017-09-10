//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Safeen Azad on 9/10/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import Foundation
import CoreData

public class PhotoMap: NSManagedObject{
    
    convenience init(index: Int, imageURL: String, imageData: NSData, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context){
            self.init(entity: ent, insertInto: context)
            self.index = Int16(index)
            self.imageURL = imageURL
            self.imageData = imageData
            
        }else {
            fatalError("Unable to find the Entity name.")
        }
    }
    
}

extension PhotoMap {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoMap> {
        
        return NSFetchRequest<PhotoMap>(entityName: "Photo");
    }
    
    @NSManaged public var imageData: NSData?
    @NSManaged public var imageURL: String?
    @NSManaged public var index: Int16
    @NSManaged public var pin: PinMap?
    
}
