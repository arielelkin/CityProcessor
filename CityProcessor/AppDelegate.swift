//
//  AppDelegate.swift
//  CityProcessor
//
//  Created by Ariel Elkin on 22/01/2018.
//  Copyright © 2018 Backbase. All rights reserved.
//

import UIKit
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()



        return true
    }

    fileprivate func parseCitiesJSON() throws -> [City] {

        var result = [City]()

        guard let jsonPath = Bundle.main.path(forResource: "cities", ofType: "json") else {
            assertionFailure()
            return [City]()
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath), options: [.uncached])
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)

            if let cityArray = jsonResult as? [AnyObject] {
                print(cityArray.first!)

                for cityJSON in cityArray {
                    if let cityName = cityJSON["name"] as? String,
                        let countryCode = cityJSON["country"] as? String,
                        let cityID = cityJSON["_id"] as? Int
                    {
                        let city = City(id: cityID, name: cityName, countryCode: countryCode, coordinate: CLLocationCoordinate2D.init())
                        result.append(city)
                    }
                }
            }
            else {
                assertionFailure()
            }
        } catch {
            assertionFailure("\(error)")
            throw error
        }
        return result
    }
}

