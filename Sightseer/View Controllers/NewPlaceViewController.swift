//
//  NewPlaceViewController.swift
//  Traveller
//
//  Created by Anthony on 10/01/20.
//  Copyright © 2020 EmeraldApps. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

/// function for presented view controller to pass back location details
protocol LocationSearchDelegate {
    func passLocation(placemark: CLPlacemark)
}

class NewPlaceViewController: UIViewController, LocationSearchDelegate {
    
    public enum Category: String {
        case landmark = "Landmark"
        case activity = "Activity"
        case food = "Food/Drink"
        case other = "Other"
    }
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var ratingTextField: UITextField!
    @IBOutlet weak var ratingSlider: UISlider!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    
    var location: CLPlacemark?
    var selectedCategory = Category.landmark
    var capturedImage = UIImage()
    var activitySpinner = CustomActivityIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

    /// text field validation vars
    var areTextFieldsComplete = false
    var textFieldErrors = [String]()
    var nameError = "Name field must not be empty"
    var cityError = "City field must not be empty"
    var countryError = "Country field must not be empty"
    var ratingError = "Please rate this place"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activitySpinner.center = view.center
        view.addSubview(activitySpinner)
        setUpSegmentedControl()
        setUpRightBarButton()
        setUpShareButton()
        setUpImage()
        setUpDescriptionTextView()
        hideKeyboardWhenTapped()
        addObservers()
        descriptionTextView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }

    // MARK: - Delegate Method
    /// Set text fields received from delegate
    func passLocation(placemark: CLPlacemark) {
        nameTextField.text = placemark.name
        cityTextField.text = placemark.locality
        countryTextField.text = placemark.country
        location = placemark
    }
    
    // MARK: - Text field validation
    func textFieldsValidated() -> Bool {
        textFieldErrors = [String]()
        areTextFieldsComplete = true
        if nameTextField.text?.count ?? 0 < 1 {
            areTextFieldsComplete = false
            textFieldErrors.append(nameError)
            textFieldErrors.append(cityError)
            textFieldErrors.append(countryError)
        }
        if ratingTextField.text?.count ?? 0 < 1 {
            areTextFieldsComplete = false
            textFieldErrors.append(ratingError)
        }
        if !areTextFieldsComplete {
            var textFieldErrorMessage = ""
            for message in textFieldErrors {
                textFieldErrorMessage += "\u{2022} \(message)\n"
            }
            presentAlert(title: "Please fix the errors below", message: textFieldErrorMessage)
        }
        return areTextFieldsComplete
    }
    
    // MARK: - View Setup
       func setUpSegmentedControl(){
           let attributes = [ NSAttributedString.Key.foregroundColor : UIColor(named: "AppPrimary"),
                              NSAttributedString.Key.font : UIFont(name: "Futura", size: 14.0)];
            let attributesSelected = [ NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "Futura", size: 14.0)];
           categorySegmentedControl.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .normal)
           categorySegmentedControl.setTitleTextAttributes(attributesSelected as [NSAttributedString.Key : Any], for: .selected)
           categorySegmentedControl.tintColor = UIColor(named: "AppPrimary")
    
       
       }
    
    func setUpDescriptionTextView(){
        descriptionTextView.layer.borderWidth = 2
        descriptionTextView.layer.borderColor = UIColor(named: "AppPrimary")?.cgColor
        descriptionTextView.layer.cornerRadius = 5
    }
    
    func setUpShareButton() {
        shareButton.addShadow()
        shareButton.layer.cornerRadius = 5
    }
    
    func setUpImage() {
        placeImage.image = capturedImage
        
    }
    
    /// presents location search view controller
    func presentLocationSearchView(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "searchResultTableViewController") as! SearchResultTableViewController
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Text field manipulation
    func disableTextFields(){
        nameTextField.isUserInteractionEnabled = false
        cityTextField.isUserInteractionEnabled = false
        countryTextField.isUserInteractionEnabled = false
    }
    
    func enableTextFields(){
        nameTextField.isUserInteractionEnabled = true
        cityTextField.isUserInteractionEnabled = true
        countryTextField.isUserInteractionEnabled = true
    }
    
    // MARK: - IBActions
    @IBAction func categoryChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
         case 0:
            selectedCategory = Category.landmark
            break
         case 1:
            selectedCategory = Category.activity
             break
        case 2:
            selectedCategory = Category.food
             break
        case 3:
            selectedCategory = Category.other
             break
         default:
             print("Unknown index")
         }
        print(selectedCategory.rawValue)
    }
    
    
    @IBAction func ratingSliderChanged(_ sender: UISlider) {
        ratingTextField.text = String(Int(sender.value * 10)) + " out of 10"
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func addLandmarkButtonClicked(_ sender: Any) {
        if textFieldsValidated() {
            /// multiplying ratingby 200 to decide how much points visiting the place is worth
            let points = Int(roundf(ratingSlider.value * 10) * 200)
            print(roundf(ratingSlider.value * 10) * 200)
            
            shareButton.disable()
            activitySpinner.startAnimating()
               
            /// adding place to database
            if let placemark = location {
                
            Service.sharedInstance.addPlaceToDatabase(points: points, placemark: placemark, category: selectedCategory.rawValue, description: descriptionTextView.text, image: capturedImage) { [weak self](succeeded) in
                    
                    guard let this = self else { return }
                    this.activitySpinner.stopAnimating()
                    this.shareButton.enable()
                    if succeeded {
                        this.navigationController?.popToRootViewController(animated: false)
                        
                    } else {
                        this.presentAlert(title: "Error", message: "Unable to add new place to database")
                    }
                }
            }
        }
    }
       
       @IBAction func textFieldClicked(_ sender: UITextField) {
            /// linked to name, city and country text field
            /// stops editing and presents location search screen
            sender.endEditing(true)
            self.presentLocationSearchView()
       }
}

// MARK: - Text View Delegate
extension NewPlaceViewController : UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        nameTextField.isUserInteractionEnabled = false
        cityTextField.isUserInteractionEnabled = false
        countryTextField.isUserInteractionEnabled = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        nameTextField.isUserInteractionEnabled = true
        cityTextField.isUserInteractionEnabled = true
        countryTextField.isUserInteractionEnabled = true
    }
}
