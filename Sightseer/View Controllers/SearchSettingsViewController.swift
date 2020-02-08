//
//  SearchSettingsViewController.swift
//  Traveller
//
//  Created by Anthony on 4/10/19.
//  Copyright © 2019 EmeraldApps. All rights reserved.
//

import UIKit
import CoreLocation

class SearchSettingsViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var currentDistanceLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var updateSettingsButton: UIButton!
    
    var locationManager = CLLocationManager()
    var wordwideSelected = false
    var activitySpinner = CustomActivityIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))


    override func viewDidLoad() {
        super.viewDidLoad()
        
        activitySpinner.center = view.center
        view.addSubview(activitySpinner)
        view.setUpBackgroundColour()
        setUpUpdateButton()
        setUpContainer()
        setUpDistanceLabelAndSlider()
        
        /// gets current location and sets text fields
        lookUpCurrentLocation { [weak self] (placemark) in
            guard let this = self else { return }
            guard let city = placemark?.subAdministrativeArea else { return }
            guard let state = placemark?.administrativeArea else { return }
            this.currentLocationLabel.text = "\(city), \(state)"
        }
    }
    
    // MARK: - Location lookup
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
                    -> Void ) {
        // Use the last reported location.
        if let lastLocation = locationManager.location {
            let geocoder = CLGeocoder()
                
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                        completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                }
                else {
                 /// An error occurred during geocoding.
                    completionHandler(nil)
                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
            presentAlert(title: "Location Unavailable", message: "We were unable to get your current location")
        }
    }
    
    // MARK: - View Setup
    private func setUpUpdateButton(){
        updateSettingsButton.layer.cornerRadius = 5
        updateSettingsButton.addShadow()
    }
    
    private func setUpContainer(){
        containerView.layer.cornerRadius = 10
        containerView.addShadow()
    }
    
    private func setUpDistanceLabelAndSlider(){
        // setting max slider to 200km
        currentDistanceLabel.text = String(CURRENTUSER.searchRadius) + "km"
        distanceSlider.value = Float(CURRENTUSER.searchRadius) / Float(200)
    }
    

    // MARK: - IBActions
    @IBAction func sliderChanged(_ sender: UISlider) {
        currentDistanceLabel.text = String(Int(sender.value * 200)) + "km"
    }
    @IBAction func updateSettingsButtonClicked(_ sender: Any) {
        let searchRadius = Int(distanceSlider.value * 200)
        let values = [
            "searchRadius" : searchRadius
        ] as [String : Any]
        activitySpinner.startAnimating()
        updateSettingsButton.disable()
        Service.sharedInstance.updateUserDiscoveryDetails(id: CURRENTUSER.id, values: values){ [weak self] (succeeded) in
            guard let this = self else {return}
            this.activitySpinner.stopAnimating()
            this.updateSettingsButton.enable()
            if succeeded {
                this.navigationController?.popViewController(animated: true)
            } else {
                this.presentAlert(title: "Error", message: "Unable to update discovery details")
            }
        }
    }
}
