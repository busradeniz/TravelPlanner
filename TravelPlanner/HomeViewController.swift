//
//  ViewController.swift
//  TravelPlanner
//
//  Created by Busra Deniz on 02/12/15.
//  Copyright © 2015 busradeniz. All rights reserved.
//

import UIKit
import CloudKit
import MapKit


class HomeViewController: UIViewController , CLLocationManagerDelegate,MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let locationManager = CLLocationManager()
    var travelPlanList : [TravelPlan]  = []


    @IBOutlet weak var tblTravelPlanner: UITableView!
    @IBOutlet weak var mkMapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }else {
            print("locationServicesDisabled")
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        getTravelPlanList()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.currentLocation = manager.location!.coordinate
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let span = MKCoordinateSpanMake(27,27)
        let region = MKCoordinateRegion(center:locValue, span: span)
        mkMapView.setRegion(region, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func getTravelPlanList(){
        
        //TODO add loader
        travelPlanList.removeAll()
        let container = CKContainer.defaultContainer()
        let publicData = container.publicCloudDatabase
        let query = CKQuery(recordType: "TravelPlan" ,predicate: NSPredicate(format: "TRUEPREDICATE") )
        
        
        
        publicData.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil { // There is no error
                for plan in results! {
                    let travelPlan = TravelPlan()
                    travelPlan.title = plan["Title"] as? String
                    travelPlan.description = plan["Description"] as? String
                    travelPlan.date = plan["Date"] as? String
//                    travelPlan.photos = plan ["Photos"] as! [CKAsset]
                    travelPlan.latitude = plan ["Latitude"] as? Double
                    travelPlan.longitude = plan ["Longitude"] as? Double
                    self.travelPlanList.append(travelPlan)
                    print("Travel Plan : " + travelPlan.title!)
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.addMarkers()
                    self.tblTravelPlanner.reloadData()
                })
            }
            else {
                print(error)
            }
        }

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return travelPlanList.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //TODO liste cell ini düzenle, foto ekle
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "myCell")
         cell.textLabel!.text = self.travelPlanList[indexPath.row].title
        return cell

    }
    
    func addMarkers(){
        for travel in self.travelPlanList {
           let artwork  = MapPin(coordinate: CLLocationCoordinate2D(latitude: travel.latitude!, longitude:travel.longitude!), title: travel.title!, subtitle: travel.description!)
            mkMapView.addAnnotation(artwork)
        }
    }
    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MapPin {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let capital = view.annotation as! MapPin
        let placeName = capital.title
        let placeInfo = capital.subtitle
        
        //TODO tıklayınca travel detayına gidecek
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    
    
    
    
   

    

}

