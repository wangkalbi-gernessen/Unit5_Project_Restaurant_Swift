//
//  OrderConfirmationViewController.swift
//  Unit5_Restaurant
//
//  Created by Kazunobu Someya on 2021/01/17.
//

import UIKit

class OrderConfirmationViewController: UIViewController {

    let minutesToPrepare: Int
    @IBOutlet var confimationLabel: UILabel!
    
    
    init?(coder: NSCoder, minutesToPrepare: Int) {
        self.minutesToPrepare = minutesToPrepare
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        confimationLabel.text = "Thank you for your order! Your wait time is approximately \(minutesToPrepare) minutess."
    }
}
