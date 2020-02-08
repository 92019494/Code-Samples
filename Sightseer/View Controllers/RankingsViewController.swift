//
//  RankingsViewController.swift
//  Traveller
//
//  Created by Anthony on 30/09/19.
//  Copyright © 2019 EmeraldApps. All rights reserved.
//

import UIKit
import Firebase

class RankingsViewController: UIViewController {
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var users = [User]()
    var toolBar = UIToolbar()
    var picker  = UIPickerView()

    /// limit amount of posts first loaded
    var startingLimit = 8
    var limit = 8
    var limitIncrement = 5
    var fetchingMore = false
    var allUsersFetched = false
    
    // filter options need to match cases in Service file
    var filterOptions = ["country", "world"]
    var filterOptionSelected = "country"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpRefreshControl()
        view.backgroundColor = UIColor(named: "BackgroundColor")
        
        setUpNavBarAppearance()
        setUpRightBarButton()
        setUpNavBackButton()
        registerLoadingCell()
    }
    
    // MARK: - Picker View
    @IBAction func filterButtonClicked(_ sender: Any) {
        filterButton.isEnabled = false
        picker = UIPickerView.init()
        picker.delegate = self
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        view.addSubview(picker)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = UIBarStyle.default
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        view.addSubview(toolBar)
        
    }
    
    @objc func onDoneButtonTapped() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
        filterButton.isEnabled = true
        switch filterOptionSelected {
        case filterOptions[0]:
            fetchTopUsersInCountry()
        case filterOptions[1]:
            fetchTopUsersInWorld()
        default:
            break
        }
    }
    
    // MARK: - Register loading cell
    func registerLoadingCell(){
         let loadingNib = UINib(nibName: "LoadingCell", bundle: nil)
         tableView.register(loadingNib, forCellReuseIdentifier: "loadingCell")
     }
     
    // MARK: - Refresh control
    func setUpRefreshControl(){
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(named: "TitleGrey")
        refreshControl.addTarget(self, action: #selector(handleRefresh(_ :)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        switch filterOptionSelected {
        case filterOptions[0]:
            fetchTopUsersInCountry()
        case filterOptions[1]:
            fetchTopUsersInWorld()
        default:
            break
        }
        refreshControl.endRefreshing()
    }
    
    // MARK: - Fetch users
    func fetchTopUsersInCountry() {
        Service.sharedInstance.fetchTopUsersInCountry(user: CURRENTUSER, limit: limit) { [weak self ](topUsers) in
            guard let this = self else { return }
            this.fetchingMore = false
            if this.users.count == topUsers.count {
                this.allUsersFetched = true
            }
            DispatchQueue.main.async {
                this.users = topUsers
                this.tableView.reloadData()
            }
        }
    }
    
    func fetchTopUsersInWorld() {
        Service.sharedInstance.fetchTopUsersInWorld(limit: limit) { [ weak self ] (topUsers) in
            
            guard let this = self else { return }
            this.fetchingMore = false
            if this.users.count == topUsers.count {
                this.allUsersFetched = true
            }
            DispatchQueue.main.async {
                this.users = topUsers
                this.tableView.reloadData()
            }
        }
    }
}

// MARK: - Tableview Setup
extension RankingsViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return users.count
        } else if section == 1 && fetchingMore && !allUsersFetched{
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardCell", for: indexPath) as! LeaderboardTableViewCell
            let user = users[indexPath.row]
            cell.numberLabel.text = "#" + String(indexPath.row + 1)
            cell.nameLabel.text = user.name
            cell.countryLabel.text = user.country
            cell.pointsLabel.text = user.pointsString()
            
            let url = URL(string: users[indexPath.row].imageURL)
            cell.profileImage.kf.setImage(with: url, placeholder: UIImage(named: "default"))
            
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            presentProfile(userID: users[indexPath.row].id)
        }
    }
}

// MARK: - PickerView Setup
extension RankingsViewController:  UIPickerViewDelegate, UIPickerViewDataSource {
 
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filterOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filterOptions[row].capitalized
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        /// resetting limit value used when fetching users
        limit = startingLimit
        allUsersFetched = false
        filterOptionSelected = filterOptions[row]
    }
}

// MARK: - Scroll View Delegate
extension RankingsViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !fetchingMore && !allUsersFetched{
                fetchingMore = true
                limit += limitIncrement
                tableView.reloadSections(IndexSet(integer: 1), with: .none)
                
                switch filterOptionSelected {
                case filterOptions[0]:
                    fetchTopUsersInCountry()
                case filterOptions[1]:
                    fetchTopUsersInWorld()
                default:
                    break
                }
                
            }
        }
    }
}
