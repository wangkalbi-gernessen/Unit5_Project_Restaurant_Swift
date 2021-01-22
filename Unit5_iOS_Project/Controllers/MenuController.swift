//
//  MenuController.swift
//  Unit5_Restaurant
//
//  Created by Kazunobu Someya on 2021/01/17.
//

import Foundation
import UIKit

class MenuController {
    // shared all across the VCs (like shared instance of URLSession)-> no need to create instance of this class per VC because of this
    static let shared = MenuController()
    
    // notify order changes
    static let orderUpdatedNotification = Notification.Name("MenuController.orderUpdated")
    
    var order = Order() {
        didSet {
            NotificationCenter.default.post(name: MenuController.orderUpdatedNotification, object: nil)
        }
    }
    
    let baseURL = URL(string: "http://localhost:8090/")!
    
    // GET for categories. request to /categories
    func fetchCategories(completion: @escaping ((Result<[String], Error>) -> Void)){
        // create URL
        let categoriesURL = baseURL.appendingPathComponent("categories")
        // make a request
        let task = URLSession.shared.dataTask(with: categoriesURL) { (data, response, error) in
            if let data = data {
                do {
                    let jsonDecoder = JSONDecoder()
                    let categoriesResponse = try jsonDecoder.decode(CategoriesResponse.self, from: data)
                    completion(.success(categoriesResponse.categories))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // GET for items within a category. request to /menu
    func fetchMenuItem(forCategory categoryName: String, completion: @escaping ((Result<[MenuItem], Error>) -> Void)){
       // create a URL
        let baseMenuURL = baseURL.appendingPathComponent("menu")
        // Use compontns to dynamically add query items
        var components = URLComponents(url: baseMenuURL, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "category", value: categoryName)]
        let menuURL = components.url!
        
        let task = URLSession.shared.dataTask(with: menuURL) { (data, response, error) in
            if let data = data {
                do {
                    let jsonDecoder = JSONDecoder()
                    let menuResponse = try jsonDecoder.decode(MenuResponse.self, from: data)
                    completion(.success(menuResponse.items))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // takes imageURL, completion handler receives UIImage data
    func fetchImage(url: URL, completion: @escaping (UIImage?)
       -> Void) {
        let task = URLSession.shared.dataTask(with: url)
           { (data, response, error) in
            if let data = data,
                let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
 
    typealias MinutesToPrepare = Int

    // POST containing the user's order
    func submitOrder(forMenuIDs menuIds: [Int], completion: @escaping ((Result<MinutesToPrepare, Error>) -> Void)) {
        let orderURL = baseURL.appendingPathComponent("order")
        
        // modify request default type from GET to POST
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        // tell the server that JSON data will be sending
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // store array of menuIDs in JSON
        let data = ["menuIds": menuIds]
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(data)
        
        // data for POST must be stored in the body of the request
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let jsonDecoder = JSONDecoder()
                    let orderResponse = try jsonDecoder.decode(OrderResponse.self, from: data)
                    completion(.success(orderResponse.prepTime))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}


