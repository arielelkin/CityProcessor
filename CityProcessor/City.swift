//
//  City.swift
//  CityProcessor
//
//  Created by Ariel Elkin on 22/01/2018.
//  Copyright © 2018 Backbase. All rights reserved.
//

import MapKit

enum CityInitError: Error {
    case noValueForCoord
    case noValueForName
    case missingValue
}

struct City {
    let id: Int
    let name: String
    let countryCode: String
    let coordinates: CLLocationCoordinate2D

    let searchableName: String

    init(jsonDict: AnyObject) throws {
        var coordinates: CLLocationCoordinate2D?
        if let coordinatesDict = jsonDict["coord"] as? NSDictionary,
            let latitude = coordinatesDict["lat"] as? Double,
            let longitude = coordinatesDict["lon"] as? Double {
            coordinates = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
        }
        else {
            throw CityInitError.noValueForCoord
        }

        if let cityName = jsonDict["name"] as? String,
            let countryCode = jsonDict["country"] as? String,
            let cityID = jsonDict["_id"] as? Int,
            let coordinates = coordinates {

            self.id = cityID
            self.name = cityName
            self.countryCode = countryCode
            self.coordinates = coordinates

            self.searchableName = name.folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive], locale: nil)
        }
        else {
            if jsonDict["name"] as? String == nil {
                throw CityInitError.noValueForName
            }
            else {
                // We should ideally write an error for each possible
                // missing value in the JSONDict, but for the present
                // present purposes this illustrates the pattern
                throw CityInitError.missingValue
            }
        }
    }
}


extension Collection where Element == City {

    /*
     Filtering Strategy:

     1. Very quickly find an index in cityArray of a city with a
     prefix that matches the search key. The array is already sorted
     so a binary search is a natural choice.
     2. If found, given that the array is sorted, any additional matches
     will be found in the indices immediately before or after. Run simple
     linear searches in each direction and add them to the filteredCityArray
     displayed by the collection view.

     Further optimisations are possible:

     - Currently, a search is ran on the fully cityArray every time
     a character is added or removed from the search bar. This could
     be optimised by running a search on the filtered array.

     - Similarly, we're calling reloadData() on the collection view every
     time a character is added or removed from the search bar. This could be
     optimised by manually adding or removing cells from the collection view.

     - The two linear searches following the binary search happen sequentially.
     They could instead each be wrapped into Operations and run in parallel.

     - This extension could be refactored to work with any given predicate with
     any given type of Element (it may come in handy if we ever wish to filter
     by country codes, for example).

     */
    func filteredByPrefix(_ searchKey: String) -> [City] {

        let cityArray = self as! [City]

        var filteredCityArray = [City]()

        if let midIndex = binarySearch(cityArray, key: searchKey, range: 0 ..< cityArray.count) {

            filteredCityArray.append(cityArray[midIndex])

            for index in stride(from: midIndex+1, to: cityArray.count-1, by: 1) {
                if cityArray[index].searchableName.hasPrefix(searchKey) {
                    filteredCityArray.append(cityArray[index])
                }
                else {
                    break
                }
            }

            var precedingEntries = [City]()
            for index in stride(from: midIndex-1, to: 0, by: -1) {
                if cityArray[index].searchableName.hasPrefix(searchKey) {
                    precedingEntries.append(cityArray[index])
                }
                else {
                    break
                }
            }
            filteredCityArray.insert(contentsOf: precedingEntries.reversed(), at: 0)
        }

        return filteredCityArray
    }

    // Implementation based on
    // https://github.com/raywenderlich/swift-algorithm-club/tree/master/Binary%20Search
    fileprivate func binarySearch(_ array: [City], key: String, range: Range<Int>) -> Int? {
        
        if range.lowerBound >= range.upperBound {
            // If we get here, then the search key is not present in the array.
            return nil
            
        } else {
            // Calculate where to split the array.
            let midIndex = range.lowerBound + (range.upperBound - range.lowerBound) / 2
            
            if array[midIndex].name.lowercased().hasPrefix(key) {
                // We found the index of a city with a
                // prefix that matches the search key
                return midIndex
            }
            else {
                
                // Is the search key in the left half?
                if array[midIndex].name.lowercased() > key {
                    return binarySearch(array, key: key, range: range.lowerBound ..< midIndex)
                    
                    // Is the search key in the right half?
                } else if array[midIndex].name.lowercased() < key {
                    return binarySearch(array, key: key, range: midIndex + 1 ..< range.upperBound)
                    
                    // If we get here, then we've found the search key!
                } else {
                    return midIndex
                }
            }
        }
    }
}
