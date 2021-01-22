//
//  OrderTableViewController.swift
//  Unit5_Restaurant
//
//  Created by Kazunobu Someya on 2021/01/17.
//

import UIKit

class OrderTableViewController: UITableViewController {

    var minutesToPrepareOrder = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
      
        // when order is updated, reload tableVIew to present multiple orders
        NotificationCenter.default.addObserver(tableView!, selector: #selector(UITableView.reloadData), name: MenuController.orderUpdatedNotification, object: nil)
    }

    // dismiss action
    @IBAction func unwindToOrderList(_ sender: UIStoryboardSegue) {
        if sender.identifier == "dismissConfirmation" {
            MenuController.shared.order.menuItems.removeAll()
        }
    }

    @IBAction func submitTapped(_ sender: Any) {
        let orderTotal = MenuController.shared.order.menuItems.reduce(0.0) { (result, menuItem) -> Double in
            return result + menuItem.price
        }
        
        let formattedTotal = MenuItem.priceFormatter.string(from: NSNumber(value:orderTotal)) ?? "\(orderTotal)"
        
        let alertController = UIAlertController(title: "Confirm Order", message: "You are about to submit your order with a total of \(formattedTotal)", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: {_ in self.uploadOrder()}))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
   
    
    func uploadOrder() {
        let menuIds = MenuController.shared.order.menuItems.map
           { $0.id }
        MenuController.shared.submitOrder(forMenuIDs: menuIds)
           { (result) in
            switch result {
            case .success(let minutesToPrepare):
                DispatchQueue.main.async {
                    self.minutesToPrepareOrder = minutesToPrepare
                    self.performSegue(withIdentifier: "confirmOrder",
                       sender: nil)
                    print("seque perfom")
                }
            case .failure(let error):
                self.displayError(error, title: "Order Submission Failed")
            }
        }
    }
    
    func displayError(_ error: Error, title: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        }
    }
    
    // when confirmed on alert
    @IBSegueAction func confirmOrder(_ coder: NSCoder) -> OrderConfirmationViewController? {
        return OrderConfirmationViewController(coder: coder, minutesToPrepare: minutesToPrepareOrder)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuController.shared.order.menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Order", for: indexPath)
        configure(cell, forItemsAt: indexPath)
        return cell
    }

    func configure(_ cell: UITableViewCell, forItemsAt indexPath: IndexPath) {
        let menuItem = MenuController.shared.order.menuItems[indexPath.row]
        cell.textLabel?.text = menuItem.name
        cell.detailTextLabel?.text = MenuItem.priceFormatter.string(from: NSNumber(value: menuItem.price))
        
        MenuController.shared.fetchImage(url: menuItem.imageURL) { (image) in
            guard let image = image else { return }
            DispatchQueue.main.async {
                if let currentIndexPath = self.tableView.indexPath(for: cell),
                   currentIndexPath != indexPath {
                    return
                }
                cell.imageView?.image = image
                cell.setNeedsLayout()
            }
        }
    }

    // cell can be swipe-to-delete
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            MenuController.shared.order.menuItems.remove(at: indexPath.row)
        }
    }
}
