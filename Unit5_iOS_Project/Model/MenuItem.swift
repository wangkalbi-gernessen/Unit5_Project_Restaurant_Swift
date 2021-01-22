//
//  MenuItem.swift
//  Unit5_Restaurant
//
//  Created by Kazunobu Someya on 2021/01/17.
//

import Foundation
// models to represents the server data

struct MenuItem: Codable {
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol =  "$"
        
        return formatter
    }()
    
    var id: Int
    var name: String
    var detailText: String
    var price:  Double
    var category: String
    var imageURL: URL
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case detailText = "description"
        case price
        case category
        case imageURL = "image_url"
    }
}
