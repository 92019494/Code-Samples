//
//  FoodSelectorTableViewController.swift
//  Super Simple Calorie Counter
//
//  Created by Anthony on 29/01/20.
//  Copyright © 2020 EmeraldApps. All rights reserved.
//

import UIKit
import CoreData

class FoodSelectorTableViewController: UITableViewController{

    var delegate:FoodSelectorDelegate?
    var foods = [Food]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpRightBarButton()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchItems()
    }
    
    /// fetches core data food items
    func fetchItems(){
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        
        /// sorts list by name field
         let nameSort = NSSortDescriptor(key:"name", ascending:true)
         fetchRequest.sortDescriptors = [nameSort]
         do {
             let foods = try PersistanceService.context.fetch(fetchRequest)
             self.foods = foods
             self.tableView.reloadData()
         }
         catch {
            print("Error fetching foods")
            presentAlert(title: "Something went wrong", message: "We were unable to load your list of foods")
         }
    }
    
    @IBAction func subtractButtonClicked(_ sender: UIButton) {
        var number = foods[sender.tag].portionAmount
        if number > 1 {
            number -= 1
            foods[sender.tag].portionAmount = number
        }
    }
    
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        var number = foods[sender.tag].portionAmount
        number += 1
        foods[sender.tag].portionAmount = number
    }
    
    
    /// subtracts current food item * portion amount calories
    @IBAction func subtractFromCaloriesButtonClicked(_ sender: UIButton) {
        let amount = foods[sender.tag].portionAmount * foods[sender.tag].calories
        delegate?.passCalorieAmount(calorieAmount: Int(amount))
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func addItemButtonClicked(_ sender: Any) {
        presentAlertVC()
    }
    
    
    /// alert vc that allows user to add a food item
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
            
            /// making sure all fields are filled in
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
                this.foods.append(food)
                this.tableView.reloadData()
            } else {
                this.presentAlert(title: "Couldn't add item", message: "Please make sure all text fields are filled in")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertVC.addAction(addAction)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        /// adding help text if theres no food items in the array
        if foods.count == 0 {
            tableView.addMessageLabel(message: "Click add item to add your first item", fontSize: 18.0)
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
        return foods.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath) as! FoodSelectorTableViewCell
        
        /// setting dynamic content
        cell.nameLabel.text = foods[indexPath.row].name
        cell.portionSizeLabel.text = foods[indexPath.row].portionSize
        cell.amountOfPortionsLabel.text = String(foods[indexPath.row].portionAmount)
        cell.calorieLabel.text = String(foods[indexPath.row].calories)
        cell.subtractFromCaloriesButton.tag = indexPath.row
        cell.subtractButton.tag = indexPath.row
        cell.addButton.tag = indexPath.row
        return cell
    }
    

    
      override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
              return true

      }
      
    
      /// adding delete action to table view
      override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

          let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
              
            
            let context = PersistanceService.context
            context.delete(self.foods[indexPath.row])
            PersistanceService.saveContext()
                  
            self.foods.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
          
            completionHandler(true)
          }
          deleteAction.backgroundColor = UIColor.red
          return UISwipeActionsConfiguration(actions: [deleteAction])

      }
}
