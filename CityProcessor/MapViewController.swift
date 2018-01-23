//
//  Map.swift
//  CityProcessor
//
//  Created by Ariel Elkin on 22/01/2018.
//  Copyright © 2018 Backbase. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    let mapView = MKMapView()

    var city: City? {
        didSet {
            if let city = city {
                title = city.name
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(
                    city.coordinates,
                    5000,
                    5000
                )
                mapView.setRegion(coordinateRegion, animated: false)
            }
            else {
                assertionFailure("we should not set city to nil on MapVC")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    fileprivate func setupUI() {

        navigationItem.largeTitleDisplayMode = .never

        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)

        let constraints = [
            "H:|[mapView]|",
            "V:|[mapView]|"
            ].flatMap {
                NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: nil, views: ["mapView": mapView])
        }
        NSLayoutConstraint.activate(constraints)
    }
}
