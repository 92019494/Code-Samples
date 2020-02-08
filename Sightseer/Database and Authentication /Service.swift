//
//  Service.swift
//  Traveller
//
//  Created by Anthony on 23/12/19.
//  Copyright © 2019 EmeraldApps. All rights reserved.
//

import Foundation
import Firebase
import MapKit
import FBSDKLoginKit

struct Service {
    
    static let sharedInstance = Service()
    let db = Firestore.firestore()
    
    // MARK: - User Auth Database Methods
    func createUserWithEmail(email: String, password: String, vc: UIViewController, completion: @escaping (_ succeeded: Bool) -> ()){
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error != nil {
                print(error.debugDescription)
                let errorCode = AuthErrorCode(rawValue: error!._code)
                switch errorCode {
                case .invalidEmail:
                    vc.presentAlert(title: "Error", message: "Email Address Invalid")
                case .emailAlreadyInUse:
                    vc.presentAlert(title: "Error", message: "Email is already in use")
                case .operationNotAllowed:
                    vc.presentAlert(title: "Error", message: "Operation forbidden")
                case .weakPassword:
                    vc.presentAlert(title: "Error", message: "Weak Password")
                default:
                    break
                }
                completion(false)
                return
            }
            guard let userID = authResult?.user.uid else {return}
            guard let email = authResult?.user.email else {return}
            self.addUserToDatabase(id: userID,email: email)
            completion(true)
            
        }
        
    }
    
    func fetchUser(userID: String, completion: @escaping (_ user: User?) -> ()){
        let query = db.collection("users").whereField("id", isEqualTo: userID)

        query.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
              print("Error fetching user document: \(error!)")
              return
            }
            guard let data = document.documents.first?.data() else {
              print("User document data was empty.")
              return
            }
            print("")
            let user = User(data: data)
            completion(user)
        }
    }
    
    func signInUserWithEmail(email: String, password: String, vc: UIViewController, completion: @escaping (_ succeeded: Bool) -> ()){
        
        Auth.auth().signIn(withEmail: email, password: password) {authResult, error in
            if error != nil {
                let errorCode = AuthErrorCode(rawValue: error!._code)
                switch errorCode {
                case .invalidEmail:
                    vc.presentAlert(title: "Error", message: "Email Address Invalid")
                case .wrongPassword:
                    vc.presentAlert(title: "Error", message: "Your password is wrong. \nNote: If you originally signed in using Facebook you have to use that authentication method to sign in")
                case .userDisabled:
                    vc.presentAlert(title: "Error", message: "It appears your account has been disabled")
                case .operationNotAllowed:
                    vc.presentAlert(title: "Error", message: "Operation forbidden")
                default:
                    break
                }
                completion(false)
                return
            }
            
            completion(true)
            
        }
    }
    
    func updateEmail(email: String, vc: UIViewController, completion: @escaping (_ result: Bool) -> ()){
        Auth.auth().currentUser?.updateEmail(to: email) { (error) in
            if error != nil {
                let errorCode = AuthErrorCode(rawValue: error!._code)
                switch errorCode {
                case .invalidEmail:
                    vc.presentAlert(title: "Error", message: "Email Address Invalid")
                case .emailAlreadyInUse:
                    vc.presentAlert(title: "Error", message: "Email is already in use")
                case .requiresRecentLogin:
                    // need to add pop up vc to allow user to reauthenticate
                    vc.presentAlert(title: "Error", message: "You need to reauthenticate to update email. Log out and log back in to resolve this")
                default:
                    break
                }
                completion(false)
                return
            }
            print("auth email updated")
            completion(true)
        }
        
    }
    
    func updatePassword(password: String, vc: UIViewController, completion: @escaping (_ result: Bool) -> ()){
        Auth.auth().currentUser?.updatePassword(to: password) { (error) in
            if error != nil {
                let errorCode = AuthErrorCode(rawValue: error!._code)
                switch errorCode {
                case .operationNotAllowed:
                    vc.presentAlert(title: "Error", message: "Operation forbidden")
                case .weakPassword:
                    vc.presentAlert(title: "Error", message: "Weak password")
                case .requiresRecentLogin:
                    // need to add pop up vc to allow user to reauthenticate
                    vc.presentAlert(title: "Error", message: "You need to reauthenticate to update password. Log out and log back in to resolve this")
                default:
                    break
                }
                completion(false)
                return
            }
            print("password updated")
            completion(true)
        }
    }
    
    func checkIfUserIdAlreadyExists(userID: String, email: String, completion: @escaping (_ succeeded: Bool) -> ()){
        let query = db.collection("users").whereField("id", isEqualTo: userID).limit(to: 1)
        
        query.getDocuments { (snapshot, error) in
            if error != nil {
                print("error getting users posts")
                return
                }
                guard let document = snapshot else {
                    print("Error fetching document: \(error!)")
                        return
                }
            
            if (document.documents.first?.data()) != nil {
                print("user already exist")
                completion(true)
            } else {
                 print("user doesnt exist")
                completion(false)
            }
        }
    }
    
    func loginWithFacebook(vc: UIViewController){
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: vc) { (result, error) in
            if let error = error {
              print("Failed to login: \(error.localizedDescription)")
              return
            }
            guard let accessToken = AccessToken.current else {
              print("Failed to get access token")
              return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)    // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential) { (user, error) in
              if let error = error {
                print("Login error: \(error.localizedDescription)")
                let errorCode = AuthErrorCode(rawValue: error._code)
                switch errorCode {
                case .invalidCredential:
                    vc.presentAlert(title: "Error", message: "Unable to sign in with Facebook")
                case .invalidEmail:
                    vc.presentAlert(title: "Error", message: "Your email is invalid")
                case .operationNotAllowed:
                    vc.presentAlert(title: "Error", message: "Operation forbidden")
                case .emailAlreadyInUse:
                    vc.presentAlert(title: "Error", message: "Email was already used using another authentication method")
                case .wrongPassword:
                    vc.presentAlert(title: "Error", message: "Your email or password is incorrect")
                case .userDisabled:
                    vc.presentAlert(title: "Error", message: "It appears your account has been disabled")
                default:
                    break
                }
                return
                }
                if let newUser = user {
                    Service.sharedInstance.checkIfUserIdAlreadyExists(userID: newUser.user.uid, email: newUser.user.email ?? "") { (userExists) in
                        if !userExists {
                            Service.sharedInstance.addUserToDatabase(id: newUser.user.uid, email: newUser.user.email ?? "")
                            print("user doesn't exist")
                        }
                        print("user exists and authenticated with facebook")
                        vc.performSegue(withIdentifier: "toHome", sender: self)
                    }
                }
            }
          }
    }
    
    func signOutUser(completion: @escaping (_ succeeded: Bool) -> ()){
             let firebaseAuth = Auth.auth()
         do {
           try firebaseAuth.signOut()
         } catch let signOutError as NSError {
           completion(false)
           print ("Error signing out: %@", signOutError)
         }
         completion(true)
     }
     
    func updateAllOfUsersProfile(id: String, updatePassword: Bool, values: [String: Any], profileImage: UIImage, email: String, password: String, vc: UIViewController, completion: @escaping (_ succeeded: Bool) -> ()){

        /// first async call
        self.updateEmail(email: email, vc: vc) { (emailUpdated) in
             if !emailUpdated {
                completion(false)
                return
             }
            
            /// second async call
            self.updateUserProfileDetails(id: id, values: values) { (profileUpdated) in
                if !profileUpdated {
                    completion(false)
                    return
                }
                
                /// third async call
                self.uploadProfilePhoto(id: id, profileImage: profileImage) { (imageUpdated) in
                    if !imageUpdated {
                        completion(false)
                        return
                    }
                    if !updatePassword { completion(true) }
                    
                    /// fourth async call
                    if updatePassword {
                        self.updatePassword(password: password, vc: vc) { (passwordUpdated) in
                            if !passwordUpdated {
                                completion(false)
                                return
                            }
                            completion(true)
                        }
                    }
                }
            }
            
        }
     }
    
    
    
    // MARK: - User Database Methods
    func addUserToDatabase(id: String, email: String){
        let docData: [String: Any] = [
            "id": id,
            "name": "",
            "email": email,
            "searchRadius": 100,
            "country": "",
            "instagramUsername": "",
            "points": 0,
            "imageURL": "",
            "worldwide": false,
            "isPrivate": false,
            "posts": 0,
            "activities": [String](),
            "placesVisited": 0,
            "achievements": [String](),
            "seen": [String](),
            "created": Timestamp(date: Date())
            
        ]
        db.collection("users").document(id).setData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
                return
            } else {
                print("User added to database!")
            }
        }
    }
    
    func updateUserDiscoveryDetails(id: String, values: [String: Any], completion: @escaping (_ succeeded: Bool) -> ()){
        let docData: [String: Any] = [
            "searchRadius": values["searchRadius"] as! Int
        ]
        db.collection("users").document(id).updateData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
                completion(false)
                return
            }
            print("Discovery details successfully updated!")
            completion(true)
        }
        
    }
    
    func updateHintsEnabled(id: String, hintsEnabled: Bool){
        let docData: [String: Any] = [
            "hintsEnabled": hintsEnabled
        ]
        db.collection("users").document(id).updateData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
                return
            }
            print("hints enabled updated!")
            
        }
    }
    
    func incrementPlacesVisitedCount(id: String, placesVisited: Int){
        let docData: [String: Any] = [
            "placesVisited": placesVisited + 1
        ]
        db.collection("users").document(id).updateData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
                return
            } else {
                print("Places visited count incremented!")
            }
        }
    }
    func incrementPostsCount(id: String, posts: Int){
        let docData: [String: Any] = [
            "posts": posts + 1
        ]
        db.collection("users").document(id).updateData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
                return
            } else {
                print("Post count incremented!")
            }
        }
    }
    
    // fetches current user then populates gloabal variable CURRENT USER
    func fetchAuthenticatedUser(completion: @escaping (_ succeeded: Bool) -> ()){
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let query = db.collection("users").whereField("id", isEqualTo: userID)

        query.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
              print("Error fetching document: \(error!)")
              completion(false)
              return
            }
            guard let data = document.documents.first?.data() else {
              print("Document data was empty.")
              completion(false)
              return
            }
            CURRENTUSER = User(data: data)
            completion(true)
        }
    }
    
    func updateUserEmailInDatabase(userID: String, email: String){
        let docData: [String: Any] = [
               "email": email
        
           ]
           db.collection("users").document(userID).updateData(docData) { err in
               if let err = err {
                   print("Error writing document: \(err)")
                   return
               }
               print("User database email successfully updated!")
           }
    }
    
    func updateUserProfileDetails(id: String, values: [String: Any], completion: @escaping (_ result: Bool) -> ()){
        let docData: [String: Any] = [
            "name": values["name"] as! String,
            "instagramUsername": values["instagramUsername"] as! String,
            "country": values["country"] as! String
     
        ]
        db.collection("users").document(id).updateData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
                completion(false)
                return
            }
            completion(true)
            print("User profile details successfully updated!")
            
        }
    }
    
    func uploadProfilePhoto(id: String, profileImage: UIImage, completion: @escaping (_ result: Bool) -> ()){
        let newURL = UUID().uuidString
        let image = profileImage
        guard let data = image.jpegData(compressionQuality: CGFloat(Variables.jpegCompression)) else {
            completion(false)
            print("error getting data from image")
            return
        }
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        let imageReference = Storage.storage().reference().child("profileImages").child(id).child(newURL)
        imageReference.putData(data, metadata: uploadMetadata) { (metadata, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(false)
                return
            }
            imageReference.downloadURL { (url, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    completion(false)
                    return
                }
                guard let url = url else {
                    // present alert
                    completion(false)
                    return
                }
                let urlString = url.absoluteString
                self.updateUserImageURL(id: id, imageURL: urlString)
                completion(true)
            }
            // moved comp from here
        }
        
    }
    
    func updateUserImageURL(id: String, imageURL: String){
        let docData: [String: Any] = [
            "imageURL": imageURL
            
        ]
        db.collection("users").document(id).updateData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
                return
            } else {
                print("profile image url successfully updated!")
            }
        }
    }
    
    func addPoints(userID: String, userPoints: Int, placePoints: Int){
        let docData =  [
            "points": userPoints + placePoints
        ]
        db.collection("users").document(userID).updateData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
                return
            } else {
                print("Points updated!")
            }
        }
        
    }
    
    func setLastPlaceVisited(userID: String, placeID: String){
        let docData =  [
            "lastPlaceVisited": placeID
        ]
        db.collection("users").document(userID).updateData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
                return
            } else {
                print("Last place visited updated!")
            }
        }
        
    }

    
    func fetchUsersActivities(user: User, completion: @escaping (_ places: [Place]) -> ())  {
        var places = [Place]()
        if user.activities.count > 0 {
            for i in 0...user.activities.count - 1 {
                let query = db.collection("places").whereField("id", isEqualTo: user.activities[i])
                
                query.getDocuments { (snapshot, error) in
                    if error != nil {
                        print("error getting users actvities")
                        completion(places)
                        return
                    }
                    guard let document = snapshot else {
                        print("Error fetching document: \(error!)")
                        completion(places)
                        return
                    }
                    guard let data = document.documents.first?.data() else {
                        print("Document data was empty.")
                        completion(places)
                        return
                    }
                    
                    let place = Place(data: data)
                    places.append(place)
                    completion(places)
                }
                
            }
            
        } else {
            completion(places)
        }
        
    }
    

    
    func resetUsersSeenList(userID: String, completion: @escaping (_ succeeded: Bool) -> ()){
        db.collection("users").document(userID).updateData([
            "seen": FieldValue.delete(),
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
                completion(false)
            } else {
                print("Document successfully updated")
                completion(true)
            }
        }
    }
    

    
    // MARK: - Place Database Methods
    func addPlaceToDatabase(points: Int, placemark: CLPlacemark, category: String, description: String, image: UIImage, completion: @escaping (_ succeeded: Bool) -> ()){
        // setting dictionary values
        let id = UUID().uuidString
        let docData: [String: Any] = [
            "id": id,
            "name": placemark.name ?? "",
            "description": description,
            "category":  category,
            "country":  placemark.country ?? "",
            "city": placemark.locality ?? "",
            "points": points,
            "imageURL": "",
            "latitude": placemark.location?.coordinate.latitude ?? 0.00,
            "longitude": placemark.location?.coordinate.longitude ?? 0.00,
            "reported": [String](),
            "verified": false,
            "created": Timestamp(date: Date())
            
        ]
        db.collection("places").document(id).setData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
                completion(false)
                return
            }
            print("Place added to database!")
            
        }
        // uploading photo for place
        guard let data = image.jpegData(compressionQuality: CGFloat(Variables.jpegCompression)) else {
            print("error getting data from image")
            completion(false)
            return
        }
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        let imageReference = Storage.storage().reference().child("placeImages").child(id)
        imageReference.putData(data, metadata: uploadMetadata) { (metadata, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(false)
                return
            }
            imageReference.downloadURL { (url, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    completion(false)
                    return
                }
                guard let url = url else {
                    completion(false)
                    return
                }
                let urlString = url.absoluteString
                self.updatePlaceImageURL(id: id, imageURL: urlString)
                completion(true)
            }
            
        }
        
    }
    
    func updatePlaceImageURL(id: String, imageURL: String){
        let docData: [String: Any] = [
            "imageURL": imageURL
            
        ]
        db.collection("places").document(id).updateData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
                return
            } else {
                print("place image url successfully updated!")
            }
        }
        
    }
    
    func addPlaceToSeen(userID: String, placeID: String){
        let docData =  [
            "seen": FieldValue.arrayUnion([placeID])
        ]
        db.collection("users").document(userID).updateData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
                return
            } else {
                print("Place added to seen list!")
            }
        }

    }
    
    
    
    func addPlaceToActivities(userID: String, placeID: String){
        let docData =  [
            "activities": FieldValue.arrayUnion([placeID])
        ]
        db.collection("users").document(userID).updateData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
                return
            } else {
                print("Place added to activities!")
            }
        }
        
    }
    

    
    func removePlaceFromActivities(userID: String, placeID: String){
        let docData =  [
            "activities": FieldValue.arrayRemove([placeID])
        ]
        db.collection("users").document(userID).updateData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
                return
            } else {
                print("Activity removed!")
            }
        }

    }
    
    
    // MARK: - Post Database Methods
    func addPostToDatabase(userID: String, userName: String, userImageURL: String, placeID: String, placeName: String, placeCity: String, placeCountry: String, placeImageURL: String, placePoints: Int, placeCategory: String, placeDescription: String,placeLatitude: Double, placeLongitude: Double, image: UIImage, completion: @escaping (_ succeeded: Bool) -> ()){
        // setting dictionary values
        let id = UUID().uuidString
        let values = [
            "postID": id,
            "placeID": placeID,
            "userID": userID,
            "userName": userName,
            "userImageURL": userImageURL,
            "placeName": placeName,
            "placeCity": placeCity,
            "placeCountry": placeCountry,
            "placeImageURL": placeImageURL,
            "placePoints": placePoints,
            "placeCategory": placeCategory,
            "placeDescription": placeDescription,
            "placeLatitude": placeLatitude,
            "placeLongitude": placeLongitude,
            "reported": [String](),
            "created": Timestamp(date: Date()),
        
            ] as [String : Any]
        
        db.collection("posts").document(id).setData(values) { err in
            if let err = err {
                print("Error writing document: \(err)")
                completion(false)
                return
            }
            print("Post added to database!")
            
        }
        // uploading photo for post
        guard let data = image.jpegData(compressionQuality: CGFloat(Variables.jpegCompression)) else {
            print("error getting data from image")
            completion(false)
            return
        }
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        let imageReference = Storage.storage().reference().child("postImages").child(id)
        imageReference.putData(data, metadata: uploadMetadata) { (metadata, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(false)
                return
            }
            imageReference.downloadURL { (url, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    completion(false)
                    return
                }
                guard let url = url else {
                    completion(false)
                    return
                }
                let urlString = url.absoluteString
                self.updatePostImageURL(id: id, imageURL: urlString)
                completion(true)
            }
        }
        
    }
    
    func updatePostImageURL(id: String, imageURL: String){
        let docData: [String: Any] = [
            "postImageURL": imageURL
            
        ]
        db.collection("posts").document(id).updateData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
                return
            } else {
                print("post image url successfully updated!")
            }
        }
        
    }
    
    func addToPlacesVisited(userID: String, placeID: String, name: String, points: Int, city: String, country: String, imageURL: String, completion: @escaping (_ succeeded: Bool) -> ()){
            
        let data = [
            "userID" : userID,
            "placeID" : placeID,
            "name": name,
            "city": city,
            "country": country,
            "points": points,
            "imageURL": imageURL
            ] as [String : Any]
            
    
        db.collection("users").document(userID).collection("placesVisited").document(placeID).setData(data) { err in
            if let err = err {
                print("Error adding post to users list: \(err)")
                completion(false)
                return
            }
            print("Post added to users list!")
            completion(true)
            
        }
    }
    
    func fetchPlacesVisited(userID: String, completion: @escaping (_ places: [PlaceVisited]) -> ()){
        var places = [PlaceVisited]()
        let query = db.collection("users").document(userID).collection("placesVisited").whereField("userID", isEqualTo: userID).order(by: "points", descending: true).limit(to: 20)
        
        query.getDocuments { (snapshot, error) in
            if error != nil {
                print("error getting users posts")
                completion(places)
                return
            }
            guard let document = snapshot else {
                print("Error fetching document: \(error!)")
                completion(places)
                return
            }
            
            for document in document.documents {
            let data = document.data()
            let place = PlaceVisited(data: data)
            places.append(place)
            }
            completion(places)
        }
        
        
    }
    
    func fetchPosts(limit: Int, completion: @escaping (_ posts: [Post]) -> ())  {
        var posts = [Post]()
        
        // getting information from users posts
        let query = db.collection("posts").order(by: "created", descending: true).limit(to: limit)
        
        query.getDocuments { (postSnapshot, error) in
            if error != nil {
                print("error getting users posts")
                completion(posts)
                return
            }
            guard let document = postSnapshot else {
                print("Error fetching document: \(error!)")
                completion(posts)
                return
            }
            if document.documents.count == 0 {
                completion(posts)
            }
            
            for document in document.documents {
            let data = document.data()
            let post = Post(data: data)
            posts.append(post)
            }
            completion(posts)
        }
    }
    
    func fetchUsersPosts(userID: String, limit: Int, completion: @escaping (_ posts: [Post]) -> ())  {
          var posts = [Post]()
              
              // getting information from users posts
        let query = db.collection("posts").whereField("userID", isEqualTo: userID).order(by: "created", descending: true).limit(to: limit)
              
              query.getDocuments { (postSnapshot, error) in
                  if error != nil {
                      print("error getting users posts")
                      completion(posts)
                      return
                  }
                  guard let document = postSnapshot else {
                      print("Error fetching document: \(error!)")
                        completion(posts)
                      return
                  }
                  
                  for document in document.documents {
                  let data = document.data()
                  let post = Post(data: data)
                  posts.append(post)
                  }
                completion(posts)
              }
        
    }
    
    // MARK: - Rankings Database Methods
    func fetchTopUsersInCountry(user: User, limit: Int, completion: @escaping(_ users: [User]) -> ()) {
        var users = [User]()
        let query = db.collection("users").whereField("country", isEqualTo: user.country).order(by: "points", descending: true).limit(to: limit)
        
        query.getDocuments { (snapshot, error) in
            if error != nil {
                print("error getting users visited places")
                completion(users)
                return
            }
            guard let document = snapshot else {
                print("Error fetching document: \(error!)")
                completion(users)
                return
            }
            for document in document.documents{
            let data = document.data()
            
            let user = User(data: data)
            users.append(user)
            }
            completion(users)
        }
         
    }
    
    func fetchTopUsersInWorld(limit: Int, completion: @escaping(_ users: [User]) -> ()) {
        var users = [User]()
        let query = Firestore.firestore().collection("users").whereField("points", isGreaterThan: -1).order(by: "points", descending: true).limit(to: limit)
        
        query.getDocuments { (snapshot, error) in
            if error != nil {
                print("error getting users visited places")
                completion(users)
                return
            }
            guard let document = snapshot else {
                print("Error fetching document: \(error!)")
                completion(users)
                return
            }
            
            for document in document.documents{
            let data = document.data()
            let user = User(data: data)
            users.append(user)
            }
            completion(users)
        }
    }
    
}
