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

    var coordinates: CLLocationCoordinate2D? {
        didSet {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(
                coordinates!,
                5000,
                5000
            )
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
