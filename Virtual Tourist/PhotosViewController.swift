//
//  PhotosViewController.swift
//  Virtual Tourist
//
//  Created by Safeen Azad on 9/9/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noPhotos: UILabel!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    //Variables
    
    var coordinateSelected:CLLocationCoordinate2D!
    let spacingBetweenItems:CGFloat = 5
    let totalCellCount:Int = 25
    
    var stack:CoreDataStack!
    var coreDataPin:Pin!
    var savedImages:[Photo] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var selectedToDelete:[Int] = []{
        
        didSet {
            
            
            if selectedToDelete.count > 0 {
                
                newCollectionButton.setTitle("Remove Selected Pictures", for: .normal)
                newCollectionButton.setTitleColor(.red, for: .normal)
                
                
            } else {
                newCollectionButton.setTitleColor(.blue, for: .normal)
                newCollectionButton.setTitle("New Collection", for: .normal)
            }
        }
    }
    
    
    //View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Flow Layout
        
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = spacingBetweenItems
        flowLayout.minimumLineSpacing = spacingBetweenItems
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        //Collection View
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //Button & Label
        
        newCollectionButton.setTitleColor(.blue, for: .normal)
        newCollectionButton.isHidden = false
        noPhotos.isHidden = true
        
        //Add To Map
        
        collectionView.allowsMultipleSelection = true
        addAnnotationToMap()
        
        //Fetch Photos
        
        let savedPhoto = preloadSavedPhoto()
        
        if savedPhoto != nil && savedPhoto?.count != 0 {
            savedImages = savedPhoto!
            noPhotos.isHidden = true
            
        }else{
            
            showNewResult()
        }
    }
    
    //Core Data Stack
    
    func getCoreDataStack() -> CoreDataStack {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    //Fetch Results
    
    func getFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let stack = getCoreDataStack()
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "pin = %@", argumentArray: [coreDataPin!])
        
        return NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    //Saved Photo
    
    func preloadSavedPhoto() -> [Photo]? {
        
        do {
            
            var photoArray:[Photo] = []
            let fetchedResultsController = getFetchedResultsController()
            try fetchedResultsController.performFetch()
            let photoCount = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            
            for index in 0..<photoCount {
                
                photoArray.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)) as! Photo)
            }
            
            return photoArray.sorted(by: {$0.index < $1.index})
            
        } catch {
            
            return nil
        }
    }
    
    
    //New Collection Action
    
    
    @IBAction func newCollectionAction(_ sender: Any) {
        
        if selectedToDelete.count > 0 {
            
            removeSelectedPicturesAtCoreData()
            unselectAllSelectedCollectionViewCell()
            savedImages = preloadSavedPhoto()!
            print("saved images \(savedImages.count)")
            
        } else {
            
            showNewResult()
        }
    }
    
    //Deselect Collection View Cell
    
    func unselectAllSelectedCollectionViewCell() {
        
        for indexPath in collectionView.indexPathsForSelectedItems! {
            
            collectionView.deselectItem(at: indexPath, animated: false)
            collectionView.cellForItem(at: indexPath)?.contentView.alpha = 1
        }
    }
    
    //Remove Photos
    
    func removeSelectedPicturesAtCoreData() {
        
        for index in 0..<savedImages.count {
            
            if selectedToDelete.contains(index) {
                
                getCoreDataStack().context.delete(savedImages[index])
            }
        }
        
        do {
            try getCoreDataStack().saveContext()
            
        } catch {
            
            print("Remove Core Data Photo Failed")
        }
        
        selectedToDelete.removeAll()
    }
    
    //Show Result
    
    func showNewResult() {
        
        newCollectionButton.isEnabled = false
        
        deleteExistingCoreDataPhoto()
        savedImages.removeAll()
        
        getFlickrImagesRandomResult { (flickrImages) in
            
            if flickrImages != nil {
                
                DispatchQueue.main.async {
                    
                    self.addCoreData(flickrImages: flickrImages!, coreDataPin: self.coreDataPin)
                    self.savedImages = self.preloadSavedPhoto()!
                    self.newCollectionButton.isEnabled = true
                    // print("Saved Images: \(self.savedImages.count)")
                }
            }
        }
    }
    
    //Add Core Data
    func addCoreData(flickrImages:[FlickrImage], coreDataPin:Pin) {
        
        for image in flickrImages {
            
            do {
                let photo = Photo(index: flickrImages.index{$0 === image}!, imageURL: image.imageURLString(), imageData: nil, context: getCoreDataStack().context)
                photo.pin = coreDataPin
                print(photo)

                try getCoreDataStack().saveContext()
                
            } catch {
                print("Add Core Data Failed")
            }
        }
    }
    
    //Delete Photo
    
    func deleteExistingCoreDataPhoto() {
        
        for image in savedImages {
            
            getCoreDataStack().context.delete(image)
        }
    }
    
    //Get Random Photos
    
    func getFlickrImagesRandomResult(completion: @escaping (_ result:[FlickrImage]?) -> Void) {
        
        var result:[FlickrImage] = []
        
        let f = Flickr()
        
        f.getFlickrImages(lat: coordinateSelected.latitude, lng: coordinateSelected.longitude) { (success, flickrImages) in
            if success {
                
                print("flicker images: \(flickrImages!.count)")
                if flickrImages!.count > self.totalCellCount {
                    var randomArray:[Int] = []
                    
                    while randomArray.count < self.totalCellCount {
                        
                        let random = arc4random_uniform(UInt32(flickrImages!.count))
                        if !randomArray.contains(Int(random)) { randomArray.append(Int(random)) }
                    }
                    
                    for random in randomArray {
                        
                        result.append(flickrImages![random])
                    }
                    
                    completion(result)
                    
                } else {
                    
                    completion(flickrImages!)
                }
                
            } else {
                completion(nil)
            }
        }
    }
    
    //Add Annotation
    
    func addAnnotationToMap() {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinateSelected
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }
    
    //Collection View Functions & Delete Index Path
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("items: \(savedImages.count)")
        return savedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CollectionViewCell
        
        cell.activityIndicator.startAnimating()
        cell.initWithPhoto(savedImages[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = UIScreen.main.bounds.width / 3 - spacingBetweenItems
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return spacingBetweenItems
    }
    
    func selectedToDeleteFromIndexPath(_ indexPathArray: [IndexPath]) -> [Int] {
        var selected:[Int] = []
        
        for indexPath in indexPathArray {
            
            selected.append(indexPath.row)
        }
        return selected
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedToDelete = selectedToDeleteFromIndexPath(collectionView.indexPathsForSelectedItems!)
        let cell = collectionView.cellForItem(at: indexPath)
        
        DispatchQueue.main.async {
            
            cell?.contentView.alpha = 0.5
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        selectedToDelete = selectedToDeleteFromIndexPath(collectionView.indexPathsForSelectedItems!)
        let cell = collectionView.cellForItem(at: indexPath)
        
        DispatchQueue.main.async {
            
            cell?.contentView.alpha = 1.0
        }
        
    }
    
    
    
    
}
