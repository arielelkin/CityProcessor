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

        let loadingVC = LoadingViewController()
        loadingVC.cityLoadingCompletion = { result in
            switch result {
            case .success(let cityArray):
                UIView.transition(
                    with: self.window!,
                    duration: 0.5,
                    options: .transitionFlipFromLeft,
                    animations: {
                        self.window?.rootViewController = UINavigationController(rootViewController: ListViewController(cityArray: cityArray))
                },
                    completion: nil
                )

            case .failure(let error):
                print(error)
            }
        }

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = loadingVC
        window?.makeKeyAndVisible()

        return true
    }
}

