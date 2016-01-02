//
//  NewTravelPlanViewController.swift
//  TravelPlanner
//
//  Created by Busra Deniz on 02/01/16.
//  Copyright © 2016 busradeniz. All rights reserved.
//

import UIKit
import MapKit
import CloudKit

class NewTravelPlanViewController: UIViewController, UITextFieldDelegate , MKMapViewDelegate {


    @IBOutlet weak var imgLocation: UIView!
    @IBOutlet weak var mkMapView: MKMapView!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtNotes: UITextField!
    @IBOutlet weak var txtTitle: UITextField!
    
    
    
    var locality:String?
    var administrativeArea:String?
    var postalCode:String?
    var country:String?
    
    var selectedLatitude:Double?
    var selectedLongitude:Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        let span = MKCoordinateSpanMake(27,27)
        let region = MKCoordinateRegion(center:appDelegate.currentLocation!, span: span)
        mkMapView.setRegion(region, animated: true)
    
        selectedLatitude = appDelegate.currentLocation!.latitude
        selectedLongitude = appDelegate.currentLocation!.latitude
    
        
        getPlaceName((appDelegate.currentLocation?.latitude)!, longitude: (appDelegate.currentLocation?.longitude)!, completion: {(answer: String?) in
        
            self.txtAddress.text = answer
        
        })
        
        
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardHeight: CGFloat = keyboardSize.height
        
        let _: CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber as CGFloat
        
        
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.view.frame = CGRectMake(0, (0 - keyboardHeight), self.view.bounds.width, self.view.bounds.height)
            }, completion: nil)
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo!
        
        let _: CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber as CGFloat
        
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.view.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
            }, completion: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        
          let coordination = mkMapView.convertPoint(CGPoint.init(x: (imgLocation.frame.origin.x ), y: (imgLocation.frame.origin.y )), toCoordinateFromView: mkMapView)
        selectedLatitude = coordination.latitude
        selectedLongitude = coordination.longitude
        
        getPlaceName((coordination.latitude), longitude: (coordination.longitude), completion: {(answer: String?) in
            
            self.txtAddress.text = answer
            
        })
        
    }
    func displayLocationInfo(placemark: CLPlacemark?) -> String
    {
        if let containsPlacemark = placemark
        {
            
            self.locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            self.postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            self.administrativeArea  = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            self.country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            
            print (locality)
            print(postalCode)
            print(administrativeArea)
            print(country)
            
            return makeAddressString()
            
        } else {
            
            return ""
            
        }
        
    }
    
    
    func makeAddressString() -> String {
        // Unwrapping the optionals using switch statement
        switch ( self.locality, self.administrativeArea, self.postalCode, self.country) {
        case let ( .Some(locality), .Some(administrativeArea), .Some(postalCode), .Some(country)):
            return "\(locality) \(administrativeArea) \(postalCode) \(country)"
        default:
            return ""
        }
    }
    
    
    func getPlaceName(latitude: Double, longitude: Double, completion: (answer: String?) -> Void) {
        
        let coordinates = CLLocation(latitude: latitude, longitude: longitude)
        
        CLGeocoder().reverseGeocodeLocation(coordinates, completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                print("Reverse geocoder failed with an error" + error!.localizedDescription)
                completion(answer: "")
            } else if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                completion(answer: self.displayLocationInfo(pm))
            } else {
                print("Problems with the data received from geocoder.")
                completion(answer: "")
            }
        })
        
    }
    
    
    
    
    @IBAction func btnBackAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnAddMedia(sender: AnyObject) {
    }

    
    @IBAction func btnSaveAction(sender: AnyObject) {
        
        if (txtTitle.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" || txtAddress.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" ) {

            let ac = UIAlertController(title: "Need Title & Address Info", message: "Please fill title field and select address on map!", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
            return
        }
        
        let container = CKContainer.defaultContainer()
        let publicData = container.publicCloudDatabase
        
        let tv =  TravelPlan()
        tv.title = txtTitle.text;
        tv.description = txtNotes.text
        tv.address = txtAddress.text
        tv.latitude = selectedLatitude
        tv.longitude = selectedLongitude
        
        let record = CKRecord(recordType: "TravelPlan")
        record.setValue(tv.title, forKey: "Title")
        record.setValue(tv.description, forKey: "Description")
        record.setValue(tv.address, forKey: "Address")
        record.setValue(tv.latitude, forKey: "Latitude")
        record.setValue(tv.longitude, forKey: "Longitude")

        publicData.saveRecord(record, completionHandler: { record, error in
            if error != nil {
                print(error)
            }
        })
        

        
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        txtNotes.resignFirstResponder()
        txtTitle.resignFirstResponder()
        txtAddress.resignFirstResponder()
        return true;
    }
    

}