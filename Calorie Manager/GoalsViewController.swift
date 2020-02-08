//
//  GoalsViewController.swift
//  Super Simple Calorie Counter
//
//  Created by Anthony on 30/01/20.
//  Copyright © 2020 EmeraldApps. All rights reserved.
//

import UIKit

class GoalsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var maleFemaleSegmentedControl: UISegmentedControl!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
    @IBOutlet weak var excersizeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var goalSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var setGoalButton: UIButton!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var dailyCaloriesLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    var dailyCaloriesStartingString = "Set A New Goal"


        
    /// starting segment variables
    /// needed to calculate daily calories
    var maleFemaleValue: Float = 5
    var exersizeValue: Float = 1.2
    var goalValue: Float = 0
    let defaults = UserDefaults.standard
        
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTapped()
        setupButtons()
        hideViews()
        setupSegmentedControls()
    
    }
    
    func setupSegmentedControls(){
        maleFemaleSegmentedControl.tintColor = UIColor(named: Colors.primary)
        excersizeSegmentedControl.tintColor = UIColor(named: Colors.primary)
        goalSegmentedControl.tintColor = UIColor(named: Colors.primary)
    }
    
    func setupButtons(){
        calculateButton.layer.cornerRadius = 10
        calculateButton.addShadow()
        setGoalButton.layer.cornerRadius = 10
        setGoalButton.addShadow()
        
    }
    
    @IBAction func maleFemaleSegmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            maleFemaleValue = 5
        case 1:
            maleFemaleValue = -161
        default:
            print("Running Male Segmented Control Default Case")
            break
        }
    }
    
    
    @IBAction func exerciseSegmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            exersizeValue = 1.2
        case 1:
            exersizeValue = 1.25
        case 2:
            exersizeValue = 1.3
        case 3:
            exersizeValue = 1.35
        case 4:
            exersizeValue = 1.4
        case 5:
            exersizeValue = 1.45
        case 6:
            exersizeValue = 1.5
        case 7:
            exersizeValue = 1.55
        default:
            print("Running Exercise Segmented Control Default Case")
            break
        }
    }
    
    @IBAction func goalSegmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            goalValue = -500
        case 1:
            goalValue = -1000
        case 2:
            goalValue = 0
        case 3:
            goalValue = 500
        case 4:
            goalValue = 1000
        default:
            print("Running Goal Segmented Control Default Case")
            break
        }
    }
    
    @IBAction func setGoalButtonClicked(_ sender: Any) {
        setGoalButton.bounceButton()
        presentAlertVC()
    }
    
    @IBAction func calculateButtonClicked(_ sender: Any) {
        calculateButton.bounceButton()
        if validateTextFields() {
            calculateDailyCalories()
        }
    }

    /// hides views until a goal is calculated
    func hideViews(){
        if dailyCaloriesLabel.text == dailyCaloriesStartingString {
            infoLabel.isHidden = true
            setGoalButton.isHidden = true
            setGoalButton.isUserInteractionEnabled = false
        }
    }
    
    func validateTextFields() -> Bool {
        if ageTextField.text?.count == 0
            || weightTextField.text?.count == 0
            || heightTextField.text?.count == 0 {
            presentAlert(title: "", message: "Please fill in all the text fields")
            return false
        }
        return true
    }
    
    /// calculates calorie goal based on the information the user entered
    func calculateDailyCalories() {
        infoLabel.isHidden = false
        setGoalButton.isHidden = false
        setGoalButton.isUserInteractionEnabled = true
        
        let age = Float(ageTextField.text!)! * Float(5)
        let weight = Float(weightTextField.text!)! * Float(10)
        let height = Float(heightTextField.text!)! * Float(6.25)
        
        let bmr = weight + height - age + maleFemaleValue
        let bmrWithExercise = bmr * exersizeValue
        
        let result = bmrWithExercise + goalValue
        let roundedResult = Int(round(result))
        
        dailyCaloriesLabel.text = String(roundedResult)
    
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
        scrollView.setContentOffset(bottomOffset, animated: true)
        
        
        
    }
    
    /// presents alert to let user know their current goal will be overwritten
    func presentAlertVC(){
        let alertVC = UIAlertController(title: "Are you sure you want to overwrite your current goal?", message: nil, preferredStyle: .alert)
        
        let continueAction = UIAlertAction(title: "Continue", style: .destructive) { [weak self] (_) in
            guard let this = self else {return}
            
            if this.dailyCaloriesLabel.text != this.dailyCaloriesStartingString {
                guard let dailyCalories = Int(this.dailyCaloriesLabel.text ?? "0") else {return}
                this.defaults.set(dailyCalories, forKey: Keys.dailyCaloriesGoalKey)
                this.defaults.set(dailyCalories, forKey: Keys.dailyCaloriesRemainingKey)
                print("daily calories updated")
                this.tabBarController?.selectedIndex = 0
            } else {
                this.presentAlert(title: "Something went wrong", message: "Unable to update calorie goal")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(continueAction)
        present(alertVC, animated: true, completion: nil)
    }
}
