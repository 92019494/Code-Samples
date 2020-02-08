//
//  ViewController.swift
//  Super Simple Calorie Counter
//
//  Created by Anthony on 29/01/20.
//  Copyright © 2020 EmeraldApps. All rights reserved.
//

import UIKit

protocol FoodSelectorDelegate{
    func passCalorieAmount(calorieAmount: Int)
}

class CalorieViewController: UIViewController , FoodSelectorDelegate {
    
    @IBOutlet weak var caloriesNumberLabel: UILabel!
    @IBOutlet weak var caloriesRemainingLabel: UILabel!
    @IBOutlet weak var eatenSomethingButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupContainerView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCaloriesRemainingAttributes()
    }

    /// sets daily calories
    /// sets text attributes depending on calories left
    func setCaloriesRemainingAttributes(){
        let caloriesRemaining = defaults.value(forKey: Keys.dailyCaloriesRemainingKey) as? Int ?? 0
        caloriesNumberLabel.text = String(caloriesRemaining)
        if caloriesRemaining >= 0 {
            caloriesNumberLabel.textColor = UIColor(named: Colors.green)
            caloriesRemainingLabel.text = "Daily Calories Remaining"
        } else {
            caloriesNumberLabel.textColor = UIColor(named: Colors.red)
            caloriesRemainingLabel.text = "Daily Calories Exceeded"
        }
        
    }
    
    func setupButtons(){
        eatenSomethingButton.layer.cornerRadius = 10
        eatenSomethingButton.addShadow()
    }
    
    func setupContainerView(){
        containerView.layer.cornerRadius = 10
    }
        
    
    func passCalorieAmount(calorieAmount:Int){
        var amount = Int(caloriesNumberLabel.text!)
        amount! -= calorieAmount

        defaults.set(amount!, forKey: Keys.dailyCaloriesRemainingKey)
        setCaloriesRemainingAttributes()
        caloriesNumberLabel.text = String(amount!)
        
    }
    
    func presentFoodSelectorVC(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "foodSelectorVC") as! FoodSelectorTableViewController
        vc.delegate = self as FoodSelectorDelegate
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func eatenSomethingButtonClicked(_ sender: Any) {
        let goal = defaults.value(forKey: Keys.dailyCaloriesGoalKey) as? Int ?? 0
        if goal == 0 {
            presentAlert(title: "No Goal Set", message: "Please go to the new goal tab and set a goal")
        } else {
            eatenSomethingButton.bounceButton()
            presentFoodSelectorVC()
        }
        
    }
    
}

