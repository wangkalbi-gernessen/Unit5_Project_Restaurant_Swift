//
//  MenuItemDetailViewController.swift
//  Unit5_Restaurant
//
//  Created by Kazunobu Someya on 2021/01/17.
//

import UIKit

class MenuItemDetailViewController: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var detailTextLabel: UILabel!
    @IBOutlet var addToOrderButton: UIButton!
    
    let menuItem: MenuItem
    
    init?(coder: NSCoder, menuItem: MenuItem) {
        self.menuItem = menuItem
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addToOrderButton.layer.cornerRadius = 5.0
        updateUI()
    }
    
    func updateUI() {
        nameLabel.text = menuItem.name
        priceLabel.text = MenuItem.priceFormatter.string(from: NSNumber(value: menuItem.price))
        detailTextLabel.text = menuItem.detailText
        
        MenuController.shared.fetchImage(url: menuItem.imageURL) { (image) in
            guard let image = image else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }

    @IBAction func orderButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: [], animations:{
            self.addToOrderButton.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            self.addToOrderButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        } ,completion: nil)
        
        // append order to the shared order obj
        MenuController.shared.order.menuItems.append(menuItem)
    }
}
