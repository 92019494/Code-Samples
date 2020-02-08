//
//  CalculatorViewController.swift
//  Super Simple Calorie Counter
//
//  Created by Anthony on 30/01/20.
//  Copyright © 2020 EmeraldApps. All rights reserved.
//

import UIKit


class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var kiloTextField: UITextField!
    @IBOutlet weak var resultTextField: UILabel!
    
    @IBOutlet weak var calculateButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpRightBarButton()
        setupCalculateButton()
        hideKeyboardWhenTapped()
        
    }
 
    
    
    @IBAction func calculateButtonClicked(_ sender: UIButton) {
        calculateButton.bounceButton()
        if kiloTextField.text?.count ?? 0 > 0 {
            guard let amount = Int(kiloTextField.text ?? "0") else {return}
            resultTextField.text = calculate(kilojoules: amount)
        } else {
            presentAlert(title: "", message: "Please fill in the text field")
        }
    }
    
    @IBAction func AddItemButtonClicked(_ sender: Any) {
        presentAlertVC()
    }
    
    
    func calculate(kilojoules: Int) -> String {
        let result = Double(kilojoules) / 4.184
        print("result: \(result)")
        let roundedResult = Int(round(result))
        print("result: \(Int(roundedResult))")
        return String(roundedResult)
    }
    
    func setupCalculateButton(){
        calculateButton.layer.cornerRadius = 10
        calculateButton.addShadow()
    }
    
    
    /// allows user to add item to their foods list
    func presentAlertVC(){
        let alertVC = UIAlertController(title: "Add Food/Drink", message: nil, preferredStyle: .alert)
        alertVC.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        alertVC.addTextField { (textField) in
            textField.placeholder = "Portion Size  e.g 100g, 1 biscuit"
        }
        alertVC.addTextField { (textField) in
            textField.placeholder = "Calories per portion"
            textField.keyboardType = .numberPad
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] (action) in
            guard let this = self else {return}
            
            var textFieldsFilledIn = true
            let name = alertVC.textFields![0].text
            let portionSize = alertVC.textFields![1].text
            let calories = Int16(alertVC.textFields![2].text ?? "0") ?? Int16(0)
            
            if name?.count == 0 || portionSize?.count == 0 || calories == 0 {
                textFieldsFilledIn = false
            }
            
            if textFieldsFilledIn {
            let food = Food(context: PersistanceService.context)
                food.name = name?.capitalized
                food.calories = calories
                food.portionSize = portionSize
                food.portionAmount = Int16(1)
                PersistanceService.saveContext()
            } else {
                this.presentAlert(title: "Couldn't add item", message: "Please make sure all text fields are filled in")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertVC.addAction(addAction)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
    }

}
