//
//  City.swift
//  CityProcessor
//
//  Created by Ariel Elkin on 22/01/2018.
//  Copyright © 2018 Backbase. All rights reserved.
//

import MapKit

struct City {
    let id: Int
    let name: String
    let countryCode: String
    let coordinates: CLLocationCoordinate2D

    let searchableName: String

    init(id: Int,
         name: String,
         countryCode: String,
         coordinates: CLLocationCoordinate2D) {
        self.id = id
        self.name = name
        self.countryCode = countryCode
        self.coordinates = coordinates
        self.searchableName = name.folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive], locale: nil)
    }
}

extension Collection where Element == City {

}
