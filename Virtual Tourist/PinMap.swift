//
//  PinMap.swift
//  Virtual Tourist
//
//  Created by Safeen Azad on 9/10/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import Foundation
import CoreData

//PinMap Class

public class PinMap: NSManagedObject {
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            
            self.init(entity: ent, insertInto: context)
            self.latitude   = latitude
            self.longitude  = longitude
            
        } else {
            
            fatalError("Unable To Find Entity Name!")
        }
    }
    
}

//PinMap Class

extension PinMap {
    
    //Fetch PinMap
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PinMap> {
        return NSFetchRequest<PinMap>(entityName: "Pin");
    }
    
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var photo: NSSet?
    
}
//Access Photo

extension PinMap {
    
    @objc(addPhotoObject:)
    @NSManaged public func addToPhoto(_ value: Photo)
    
    @objc(removePhotoObject:)
    @NSManaged public func removeFromPhoto(_ value: Photo)
    
    @objc(addPhoto:)
    @NSManaged public func addToPhoto(_ values: NSSet)
    
    @objc(removePhoto:)
    @NSManaged public func removeFromPhoto(_ values: NSSet)
    
}
