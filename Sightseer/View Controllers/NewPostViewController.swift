//
//  NewPostViewController.swift
//  Traveller
//
//  Created by Anthony on 30/10/19.
//  Copyright © 2019 EmeraldApps. All rights reserved.
//

import UIKit

class NewPostViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    var capturedImage = UIImage()
    var checkedInPlace = Place()
    var activitySpinner = CustomActivityIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activitySpinner.center = view.center
        view.addSubview(activitySpinner)
        setUpRightBarButton()
        setUpShareButton()
        setLabelText()
        setUpImage()
        hideKeyboardWhenTapped()
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    // MARK: - View Setup
    func setUpShareButton() {
        shareButton.addShadow()
        shareButton.layer.cornerRadius = 5
    }
    
    func setUpImage() {
        postImage.image = capturedImage
    }
    
    func disableTextFields(){
        nameTextField.isUserInteractionEnabled = false
        locationTextField.isUserInteractionEnabled = false
    }
    
    func setLabelText(){
        nameTextField.text = checkedInPlace.name
        locationTextField.text = "\(checkedInPlace.city), \(checkedInPlace.country)"
    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: false)
   
    }
    @IBAction func shareButtonClicked(_ sender: Any) {
        activitySpinner.startAnimating()
        shareButton.disable()
        let place = checkedInPlace
        let user = CURRENTUSER
        Service.sharedInstance.addPostToDatabase(userID: user.id, userName: user.name, userImageURL: user.imageURL, placeID: place.id, placeName: place.name, placeCity: place.city, placeCountry: place.country, placeImageURL: place.imageURL, placePoints: place.points, placeCategory: place.category, placeDescription: place.description, placeLatitude: place.latitude, placeLongitude: place.longitude, image: capturedImage)  {
            [weak self](succeeded) in
            guard let this = self else {return}
            
            this.shareButton.enable()
            this.activitySpinner.stopAnimating()
            if succeeded {
                Service.sharedInstance.incrementPostsCount(id: user.id, posts: user.posts)
                this.navigationController?.popToRootViewController(animated: false)
            } else {
                this.presentAlert(title: "Error", message: "Unable to share post")
            }
        }
        
    }
}
