//
//  ProfileViewController.swift
//  Traveller
//
//  Created by Anthony on 27/09/19.
//  Copyright © 2019 EmeraldApps. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var checkInsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var topPlacesTableViewID = "topPlacesTableViewCell"
    var topPlacesCollectionViewID = "topPlacesCollectionViewCell"
    var postsTableViewID = "postsTableViewCell"
    var postsCollectionViewID = "postsCollectionViewCell"
    
    var topPlacesCollectionView: UICollectionView!
    var postsCollectionView: UICollectionView!
    var topPlacesCellHeight = 130
    var userClicked: User?
    var userClickedID: String?
    var activitySpinner = CustomActivityIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

    var places = [PlaceVisited]()
    var posts = [Post]()
    
    /// limit amount of posts first loaded
    var limit = 9
    var limitIncrement = 9
    var fetchingMore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activitySpinner.center = view.center
        view.addSubview(activitySpinner)
        view.backgroundColor = UIColor.white
        setUpNavBarAppearance()
        setUpProfileImage()
        setUpNavBackButton()
        checkIfCurrentUsersProfile(currentUserID: CURRENTUSER.id, userClickedID: userClickedID)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchClickedOnUser()
        setUpProfileScreen()
        
    }
    
    // MARK: Fetch user
    func fetchClickedOnUser(){
        if userClickedID != nil {
            fetchPosts(userID: userClickedID!)
            fetchPlaces(userID: userClickedID!, withSpinner: true)
            Service.sharedInstance.fetchUser(userID: userClickedID!) { [weak self] (user) in
            
                guard let this = self else {return}
                if user != nil {
                    this.userClicked = user
                    this.setUpProfileScreen()
                }
            }
        } else {
            fetchPosts(userID: CURRENTUSER.id)
            fetchPlaces(userID: CURRENTUSER.id, withSpinner: true)
            setUpProfileScreen()
        }
    }
    
    // MARK: - Fetch places visited and posts
    func fetchPlaces(userID: String, withSpinner: Bool) {
        Service.sharedInstance.fetchPlacesVisited(userID: userID) {[weak self] (places) in
            guard let this = self else {return}
            if withSpinner { this.activitySpinner.startAnimating() }
           
            DispatchQueue.main.async {
                this.places = places
                this.topPlacesCollectionView.reloadData()
                if withSpinner { this.activitySpinner.stopAnimating() }
            }
        }
    }
    
    func fetchPosts(userID: String) {
        Service.sharedInstance.fetchUsersPosts(userID: userID, limit: limit) { [weak self]  (posts) in
            guard let this = self else {return}
            DispatchQueue.main.async {
                this.fetchingMore = false
                this.posts = posts
                this.postsCollectionView.reloadData()
                this.tableView.reloadData()
            }
        }
    }
    
    // MARK: View Setup
    func setUpProfileImage(){
        profileImage.layer.cornerRadius = profileImage.bounds.height / 2
        profileImage.clipsToBounds = true
        
    }
    
    func setUpProfileScreen(){
        /// sets up the screen based on who is viewing it
        if userClicked != nil {
            setProfileDynamicContent(user: userClicked!)
        } else {
            setProfileDynamicContent(user: CURRENTUSER)
        }
    }
    
    // MARK: - Checking User
    func setProfileDynamicContent(user: User){
        nameLabel.text = user.name
        postsLabel.text = String(user.posts)
        checkInsLabel.text = String(user.placesVisited)
        pointsLabel.text = String(user.points)
        
        let url = URL(string: user.imageURL)
        profileImage.kf.setImage(with: url, placeholder: UIImage(named: "default"))
    }
    
    /// checks if the current user owns the profile
    func checkIfCurrentUsersProfile(currentUserID: String, userClickedID: String?){
        guard let id = userClickedID else {return}
        if currentUserID == id {
            editProfileButton.backgroundColor = UIColor.clear
            editProfileButton.isUserInteractionEnabled = true
        } else {
            editProfileButton.backgroundColor = UIColor.white
            editProfileButton.isUserInteractionEnabled = false
        }
    }
    
    // MARK: - IBActions
    @IBAction func instagramButtonClicked(_ sender: Any) {
        if userClicked != nil {
            if userClicked!.instagramUsername != ""{
                openInstagramURL(username: userClicked!.instagramUsername)
            }
            else {
                presentAlert(title: "Error", message: "Instagram profile not connected")
            }
        } else {
            if CURRENTUSER.instagramUsername != ""{
                openInstagramURL(username: CURRENTUSER.instagramUsername)
            } else {
                presentAlert(title: "Error", message: "Instagram profile not connected")
            }
        }
    }
    

    func openInstagramURL(username: String){
        let webURL = URL(string:  "https://instagram.com/\(username)")
        
        if UIApplication.shared.canOpenURL(webURL!) {
            UIApplication.shared.open(webURL!, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - View Post Methods
    func viewPost(places: [PlaceVisited], index: Int){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewPostViewController = storyboard.instantiateViewController(withIdentifier: "viewPostViewController") as! ViewPostViewController
        
        viewPostViewController.places = places
        viewPostViewController.startPosition = index
        
        navigationController?.pushViewController(viewPostViewController, animated: true)
    }
    
    func viewPost(posts: [Post], index: Int){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewPostViewController = storyboard.instantiateViewController(withIdentifier: "viewPostViewController") as! ViewPostViewController
        
         var convertedPosts = [PlaceVisited]()
               for post in posts {
                let newPlaceStruct = PlaceVisited(name: post.placeName, city: post.placeCity, country: post.placeCountry, points: post.placePoints, imageURL: post.postImageURL)
                    convertedPosts.append(newPlaceStruct)
               }
        
        viewPostViewController.places = convertedPosts
        viewPostViewController.startPosition = index
        
        navigationController?.pushViewController(viewPostViewController, animated: true)
     }

}

extension ProfileViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: topPlacesTableViewID) as! TopPlacesTableViewCell
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: postsTableViewID) as! PostsTableViewCell
            cell.selectionStyle = .none
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let cell = cell as? TopPlacesTableViewCell {
                self.topPlacesCollectionView = cell.collectionView
                cell.collectionView.dataSource = self
                cell.collectionView.delegate = self
                cell.collectionView.reloadData()
            }
        } else if indexPath.row == 1 {
            if let cell = cell as? PostsTableViewCell {
                self.postsCollectionView = cell.collectionView
                cell.collectionView.dataSource = self
                cell.collectionView.delegate = self
                cell.collectionView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        /// setting top places collection view
        if indexPath.row == 0 {
            return 220
        } else if indexPath.row == 1 {
           
            /// if theres no posts
            if posts.count == 0 {
                return 220
            } else {
                
            /// setting height for collection view if there is posts
            var count = self.posts.count
                
            /// creating count variable to measure exactly how many rows there should be
            while count % 3 > 0 {
                count += 1
            }
            let cellHeight = view.bounds.width / CGFloat(3)
            let viewHeight = CGFloat(count) / CGFloat(3) * cellHeight + CGFloat(42)
            return viewHeight
            }
        } else {
            /// any potential new rows
            return  UITableView.automaticDimension
        }
    }
}


// MARK: - Setup CollectionView
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        /// handling top places collection view
        if collectionView == topPlacesCollectionView {
            if places.count == 0 {
                topPlacesCollectionView.addMessageLabel(message: "No places to show", fontSize: 14.0)
            } else {
                topPlacesCollectionView.backgroundView = nil
            }
            return places.count
        }
        else {
            /// handling postscollection view
            if posts.count == 0 {
                postsCollectionView.addMessageLabel(message: "No posts to show", fontSize: 14.0)
            } else {
                postsCollectionView.backgroundView = nil
            }
            return posts.count
        }
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == topPlacesCollectionView {
            let height = topPlacesCollectionView.bounds.height
            let width = height * 0.7
            return CGSize(width: width,
                          height: height)
        } else {
            let height = postsCollectionView.bounds.width / 3 - 2
            
            return CGSize(width: height,
                          height: height)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == topPlacesCollectionView {
            return 7.0
        } else {
            return 2.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == topPlacesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                topPlacesCollectionViewID, for: indexPath) as! TopPlacesCollectionViewCell
        
            cell.layer.cornerRadius = 5
            let place = places[indexPath.row]
            
            let url = URL(string: place.imageURL)
            cell.imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderImage"))
            
            cell.nameLabel.text = place.name
            cell.pointsLabel.text = place.pointsString()
            
            return cell
        } else if collectionView == postsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postsCollectionViewID, for: indexPath) as! postsCollectionViewCell
            
            let url = URL(string: posts[indexPath.row].postImageURL)
            cell.imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderImage"))
  
            return cell
            
        }
        return UICollectionViewCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == topPlacesCollectionView {
            topPlacesCollectionView.deselectItem(at: indexPath, animated: false)
            
            /// passes array and presents next vc
            viewPost(places: self.places, index: indexPath.row)
        }
        else if collectionView == postsCollectionView {
            postsCollectionView.deselectItem(at: indexPath, animated: false)

            /// passes array and presents next vc
            viewPost(posts: self.posts, index: indexPath.row)
        }
        
    }
}

extension ProfileViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !fetchingMore {
                fetchingMore = true
                limit += limitIncrement
                if userClickedID != nil {
                    fetchPosts(userID: userClickedID!)
                } else {
                    fetchPosts(userID: CURRENTUSER.id)
                }
            }
        }
    }
}
