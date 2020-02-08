//
//  HomeViewController.swift
//  Traveller
//
//  Created by Anthony on 26/09/19.
//  Copyright © 2019 EmeraldApps. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import Kingfisher
import FBSDKLoginKit
import Reachability


class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    /// network reachability variabless
    var reachability: Reachability?
    let hostName = "google.com"
    
    /// limit amount of posts first loaded
    var limit = 10
    var limitIncrement = 3
    var fetchingMore = false
    var allPostsFetched = false
    
    var posts = [Post]()
    let locationManager = CLLocationManager()
    var activitySpinner = CustomActivityIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

    override func viewDidLoad() {
        super.viewDidLoad()
        /// fetches user
        /// if user hasn't set personal information the edit profile screen will be presented
        Service.sharedInstance.fetchAuthenticatedUser { [weak self ](succeeded) in
            guard let this = self else {return}
            if CURRENTUSER.name == "" {
                this.performSegue(withIdentifier: "toEditProfile", sender: self)
            }
        }
        startReachabiltyNotifier()
        registerLoadingCell()
        setUpNavBackButton()
        setUpRefreshControl()
        view.setUpBackgroundColour()
        setUpRightBarButton()
        setUpNavBarAppearance()
        checkLocationServices()
        view.addSubview(activitySpinner)
        activitySpinner.center = view.center
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkLocationAuthorization()
        tabBarController?.tabBar.isHidden = false
        
    }
    
    deinit {
        stopNotifier()
    }
    
    // MARK: - Register Loading Cell
    /// used when user scrolls to the bottom of the feed
    func registerLoadingCell(){
        let loadingNib = UINib(nibName: "LoadingCell", bundle: nil)
        tableView.register(loadingNib, forCellReuseIdentifier: "loadingCell")
    }

    // MARK: - Reachability
    func startReachabiltyNotifier(){
        /// gives enough time for the view to check if the user has filled in profile details or not - name, country etc
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3){ [weak self] () in
            guard let this = self else {return}
            this.startHost()
        }
        
    }

    // MARK: - Fetch Posts
    func fetchPosts(){
        Service.sharedInstance.fetchPosts(limit: limit) { [weak self](posts) in
            guard let this = self else { return }
            this.fetchingMore = false
            if this.posts.count == posts.count {
                this.allPostsFetched = true
            }
            
            DispatchQueue.main.async {
                this.posts = posts
                this.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Location
    func setupLocationManager() {
        let this = self
        locationManager.delegate = (this as CLLocationManagerDelegate)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 20.0
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            startUpdatingUserLocation()
        case .denied:
            // Show alert instructing them how to turn on permissions
            self.presentLocationAlert()
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        @unknown default:
            // show alert saying our app is currently being updated
            fatalError()
        }
    }
    
    func startUpdatingUserLocation() {
        locationManager.startUpdatingLocation()
 
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
        /// else case already handled when checking for authorisation
    }
    
    // MARK: - Refresh Control
    func setUpRefreshControl(){
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(named: "TitleGrey")
        refreshControl.addTarget(self, action: #selector(handleRefresh(_ :)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        fetchPosts()
        refreshControl.endRefreshing()
    }
 
    // MARK: - IBActions
    @IBAction func viewProfileButtonClicked(_ sender: UIButton) {
        print(posts[sender.tag].userName + "s profile was clicked")
        presentProfile(userID: posts[sender.tag].userID)
    }
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        print(posts[sender.tag].placeName + " was added to activities")
        Service.sharedInstance.addPlaceToActivities(userID: CURRENTUSER.id, placeID: posts[sender.tag].placeID)
    }
    
    @IBAction func logoutButtonClicked(_ sender: Any) {
        activitySpinner.startAnimating()
        Service.sharedInstance.signOutUser { [weak self](succeeded) in
            guard let this = self else { return }
            if succeeded {
                this.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            } else {
                this.presentAlert(title: "Something went wrong", message: "We were unable to sign you out")
            }
            this.activitySpinner.stopAnimating()
            
        }
        let loginManager = LoginManager()
        loginManager.logOut()
    }
    
}

// MARK: - Network Reachability
extension HomeViewController {

    func startHost() {
        stopNotifier()
        setupReachability(hostName)
        startNotifier()
    }
    
    func setupReachability(_ hostName: String?) {
        let reachability: Reachability?
        if let hostName = hostName {
            reachability = try? Reachability(hostname: hostName)
        } else {
            reachability = try? Reachability()
        }
        self.reachability = reachability
        //print("--- set up with host name: \(hostName?.description ?? "no host name")")


        reachability?.whenReachable = { reachability in
            print("Just connected to the internet")
        }
        reachability?.whenUnreachable = { reachability in
            self.presentAlert(title: "No Internet Connection", message: "Please enable internet services for the app to function correctly")
        }
        
    }
    
    func startNotifier() {
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
    }
    
    func stopNotifier() {
        reachability?.stopNotifier()
        reachability = nil
    }
}

// MARK: - Location Delegate
extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
        DispatchQueue.main.async { [weak self] in
            guard let this = self else {return}
            this.tableView.reloadData()
        }
        
    }
    
}

// MARK: - TableViewSetup
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return posts.count
        }  else if section == 1 && fetchingMore && !allPostsFetched{
            return 1
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailViewController = storyboard.instantiateViewController(withIdentifier: "placeDetailViewController") as! PlaceDetailViewController
            
            let post = posts[indexPath.row]
            let place = Place(id: post.placeID, name: post.placeName, description: post.placeDescription, category: post.placeCategory, country: post.placeCountry, city: post.placeCity, points: post.placePoints, latitude: post.placeLatitude, longitude: post.placeLongitude, reported: [String](), verified: false, checkedInCount: 0, imageURL: post.placeImageURL)
            
            detailViewController.place = place
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell
            
            let post = posts[indexPath.row]
            
            /// setting user image
            let userImageUrl = URL(string: post.userImageURL)
            cell.profileImage.kf.setImage(with: userImageUrl, placeholder: UIImage(named: "default"))
            
            /// setting post image
            let postImageUrl = URL(string: post.postImageURL)
            cell.postImage.kf.setImage(with: postImageUrl, placeholder: UIImage(named: "placeholderImage"))
            
            
            cell.userNameLabel.text = post.userName
            cell.placeNameLabel.text = post.placeName
            cell.cityLabel.text = post.cityCountryString()
            cell.pointsLabel.text = post.pointsString()
           
            if let distance = locationManager.location?.getDistanceString(latitude: posts[indexPath.row].placeLatitude, longitude: posts[indexPath.row].placeLongitude){
                    cell.locationLabel.text = distance
            }
            else {
                cell.locationLabel.text = "Unable to get current distance from location"
            }
            
            
            /// adding tags for button clicks
            cell.addButton.tag = indexPath.row
            cell.viewProfileButton.tag = indexPath.row
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
        
    }
}

// MARK: - Scroll Delegate
extension HomeViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height{
            if !fetchingMore && !allPostsFetched{
                fetchingMore = true
                tableView.reloadSections(IndexSet(integer: 1), with: .none)
                limit += limitIncrement
                
                fetchPosts()
                
            }
        }
    }
}


