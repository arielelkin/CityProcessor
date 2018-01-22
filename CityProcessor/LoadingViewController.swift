//
//  LoadingViewController.swift
//  CityProcessor
//
//  Created by Ariel Elkin on 22/01/2018.
//  Copyright © 2018 Backbase. All rights reserved.
//

import UIKit
import MapKit

enum CityLoadingError: Error {
    case noSuchFile
    case invalidJSONObject
}

enum CityLoadingResult {
    case success([City])
    case failure(Error)
}

class LoadingViewController: UIViewController {

    let label = UILabel()
    let progressView = UIProgressView()

    var cityLoadingCompletion: ((CityLoadingResult) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let startTime = CFAbsoluteTimeGetCurrent()
        do {
            let cityArray = try parseCitiesJSON()
            label.text = "Successfully parsed cities.json"
            cityLoadingCompletion?(.success(cityArray))
        }
        catch {
            label.text = "Error: \(error)"
            cityLoadingCompletion?(.failure(error))
        }
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Time elapsed: \(timeElapsed) s.")

    }

    func setupUI() {
        view.backgroundColor = .lightGray

        var viewsDict = [String: UIView]()

        label.text = "Loading cities.json"
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont(name: "HelveticaNeue-Light", size: 22)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        viewsDict["label"] = label
        view.addSubview(label)

        progressView.translatesAutoresizingMaskIntoConstraints = false
        viewsDict["progressView"] = progressView
        view.addSubview(progressView)

        let constraints = [
            "H:|-[label]-|",
            "V:[label]-20-[progressView]",
            ].flatMap {
                NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: nil, views: viewsDict)
            } + [
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                progressView.widthAnchor.constraint(equalTo: label.widthAnchor, multiplier: 0.75, constant: 0),
                progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    fileprivate func parseCitiesJSON() throws -> [City] {

        var result = [City]()

        guard let jsonPath = Bundle.main.path(forResource: "cities", ofType: "json") else {
            throw CityLoadingError.noSuchFile
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath), options: [.uncached])

            if let cityArray = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyObject] {

                for (index, cityJSON) in cityArray.enumerated() {

                    if index % 1000 == 0 {
                        self.progressView.setProgress((Float((index + 1)) / Float(cityArray.count)) - 0.2, animated: false)
                    }

                    var coordinates: CLLocationCoordinate2D?
                    if let coordinatesDict = cityJSON["coord"] as? NSDictionary,
                        let latitude = coordinatesDict["lat"] as? Double,
                        let longitude = coordinatesDict["lon"] as? Double {
                        coordinates = CLLocationCoordinate2DMake(latitude, longitude)
                    }

                    if let cityName = cityJSON["name"] as? String,
                        let countryCode = cityJSON["country"] as? String,
                        let cityID = cityJSON["_id"] as? Int,
                        let coordinates = coordinates {

                        let city = City(
                            id: cityID,
                            name: cityName,
                            countryCode: countryCode,
                            coordinates: coordinates
                        )
                        result.append(city)
                    }
                }

                result.sort{ $0.name < $1.name }

                self.progressView.setProgress(1, animated: false)
            }
            else {
                throw CityLoadingError.invalidJSONObject
            }
        } catch {
            throw error
        }
        return result
    }
}
