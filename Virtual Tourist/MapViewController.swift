//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Safeen Azad on 9/9/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePins: UILabel!
    
    // Variables
    //var gestureBegin: Bool = false
    var editMode: Bool = false
    var currentPins:[Pin] = []
    
    
    //Core Data
    
    func getCoreDataStack() -> CoreDataStack {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    //Fetch Results
    
    func getFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let stack = getCoreDataStack()
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = []
        
        return NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    //Load Saved Pin
    
    func preloadSavedPin() -> [Pin]? {
        
        do {
            
            var pinArray:[Pin] = []
            let fetchedResultsController = getFetchedResultsController()
            try fetchedResultsController.performFetch()
            let pinCount = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            for index in 0..<pinCount {
                
                pinArray.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)) as! Pin)
            }
            
            return pinArray
            
        } catch {
            
            return nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let defaults = UserDefaults.standard
        let locationData = ["lat":mapView.centerCoordinate.latitude
            , "long":mapView.centerCoordinate.longitude
            , "latDelta":mapView.region.span.latitudeDelta
            , "longDelta":mapView.region.span.longitudeDelta]
        defaults.set(locationData, forKey: "location")
    }
    
    //View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        if  let lat = defaults.value(forKey: "lat"),
            let long = defaults.value(forKey: "long"),
            let latDelta = defaults.value(forKey: "latDelta"),
            let longDelta = defaults.value(forKey: "longDelta")
            
        {
            let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat as! Double, long as! Double)
            let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta as! Double, longDelta as! Double)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(center, span)
            mapView.setRegion(region, animated: true)
        }
        
        
        
        deletePins.isHidden = true
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.addAnnotationOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(longPressGesture)
        
        mapView.delegate = self
        
        setRightBarButtonItem()
        
        let savedPins = preloadSavedPin()
        
        if savedPins != nil {
            
            currentPins = savedPins!
            
            //Add Annotation To Map
            
            for pin in currentPins {
                
                let coord = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                addAnnotationToMap(fromCoord: coord)
                
            }
        }
    }
    
    //Bar Button Item
    
    func setRightBarButtonItem() {
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    //Map View Function
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if !editMode {
            deletePins.isHidden = true
            performSegue(withIdentifier: "PinPhotos", sender: view.annotation?.coordinate)
            
            mapView.deselectAnnotation(view.annotation, animated: false)
            
        } else {
            
            removeCoreData(of: view.annotation!)
            
            mapView.removeAnnotation(view.annotation!)
        }
    }
    
    
    
    // Add Pin
    func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .began {
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            print(coordinate)
            //Now use this coordinate to add annotation on map.
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            self.mapView.addAnnotation(annotation)
            addCoreData(of: annotation)
        }
    }

    
    func addAnnotationToMap(fromCoord: CLLocationCoordinate2D) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = fromCoord
        mapView.addAnnotation(annotation)
    }
    
    //Add Core Data
    
    func addCoreData(of: MKAnnotation) {
        
        do {
            
            let coord = of.coordinate
            let pin = Pin(latitude: coord.latitude, longitude: coord.longitude, context: getCoreDataStack().context)
            try getCoreDataStack().saveContext()
            currentPins.append(pin)
            
        } catch {
            
            print("Add Core Data Failed")
        }
    }
    
    //Delete Core Data
    
    func removeCoreData(of: MKAnnotation) {
        
        let coord = of.coordinate
        for pin in currentPins {
            
            if pin.latitude == coord.latitude && pin.longitude == coord.longitude {
                
                do {
                    
                    getCoreDataStack().context.delete(pin)
                    try getCoreDataStack().saveContext()
                    
                } catch {
                    
                    print("Remove Core Data Failed")
                }
                break
            }
        }
    }

    //Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "PinPhotos" {
            
            let destination = segue.destination as! PhotosViewController
            let coord = sender as! CLLocationCoordinate2D
            destination.coordinateSelected = coord
            
            for pin in currentPins {
                
                if pin.latitude == coord.latitude && pin.longitude == coord.longitude {
                    print("selected pin: \(pin)")
                    destination.coreDataPin = pin
                    break
                }
            }
            
        }
    }
    
    //Edit
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        
        deletePins.isHidden = !editing
        editMode = editing
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let defaults = UserDefaults.standard
        defaults.setValue(mapView.centerCoordinate.latitude, forKey: "lat")
        defaults.setValue(mapView.centerCoordinate.longitude, forKey: "long")
        defaults.setValue(mapView.region.span.latitudeDelta, forKey: "latDelta")
        defaults.setValue(mapView.region.span.longitudeDelta, forKey: "longDelta")
    }
    
}

