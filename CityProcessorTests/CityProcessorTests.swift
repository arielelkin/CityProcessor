//
//  CityProcessorTests.swift
//  CityProcessorTests
//
//  Created by Ariel Elkin on 22/01/2018.
//  Copyright © 2018 Backbase. All rights reserved.
//

import XCTest
@testable import CityProcessor

class CityProcessorTests: XCTestCase {

    static let cityArrayJSON: [AnyObject] = {
        let jsonPath = Bundle.main.path(forResource: "cities", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: jsonPath), options: [.uncached])
        let cityArray = try! JSONSerialization.jsonObject(with: data, options: []) as! [AnyObject]
        return cityArray
    }()

    static let cityArray: [City] = {
        var result = [City]()
        for cityJSON in CityProcessorTests.cityArrayJSON {
            let city = try! City(jsonDict: cityJSON)
            result.append(city)
        }
        result.sort{ $0.name < $1.name }
        return result
    }()

    func testInitWithInvalidObject() {
        var city: City? = nil
        do {
            city = try City.init(jsonDict: UIImage())
            XCTFail("Should not init with invalid object")
        } catch {
            XCTAssertNil(city)
        }
    }

    func testInitWithInvalidCoordinates() {
        var city: City? = nil
        do {
            city = try City.init(jsonDict: ["coord": ["lat": UIImage()]] as AnyObject)
            XCTFail("Should not init with invalid coordinates")
        } catch {
            XCTAssertNil(city)
            XCTAssert(error is CityInitError)
        }
    }

    func testInitWithInvalidName() {
        var city: City? = nil
        do {
            city = try City.init(jsonDict: ["name": UIImage()] as AnyObject)
            XCTFail("Should not init with invalid name")
        } catch {
            XCTAssertNil(city)
            XCTAssert(error is CityInitError)
        }
    }

    func testInitWithValidData() {
        do {
            let city = try City.init(jsonDict: CityProcessorTests.cityArrayJSON.first!)
            XCTAssertEqual(city.name, "Hurzuf")
            XCTAssertEqual(city.searchableName, "hurzuf")
            XCTAssertEqual(city.countryCode, "UA")
            XCTAssertEqual(city.id, 707860)
            XCTAssertEqual(city.coordinates.latitude, 44.549999)
            XCTAssertEqual(city.coordinates.longitude, 34.283333)
        }
        catch {
            XCTFail("Should init if given valid data")
        }
    }

    func testFilteringWithCereal() {
        let results = CityProcessorTests.cityArray.filteredByPrefix("cereal")
        XCTAssert(results.count == 2)
        XCTAssert(
            results.contains {
                $0.name == "Cereal" && $0.countryCode == "CA" && $0.id == 5919289
            }
        )
        XCTAssert(
            results.contains {
                $0.name == "Cereales" && $0.countryCode == "AR" && $0.id == 3862101
            }
        )
    }

    func testFilteringWithAriel() {
        let results = CityProcessorTests.cityArray.filteredByPrefix("ariel")
        XCTAssert(results.count == 2)
        XCTAssert(
            results.contains {
                $0.name == "Ariel" && $0.countryCode == "IL" && $0.id == 8199394
            }
        )
        XCTAssert(
            results.contains {
                $0.name == "Arielli" && $0.countryCode == "IT" && $0.id == 3182850
            }
        )
    }

    func testFilteringWithNumbers() {
        let results = CityProcessorTests.cityArray.filteredByPrefix("42")
        XCTAssert(results.count == 0)
    }

    func testFilteringWithMispeltCityName() {
        let results = CityProcessorTests.cityArray.filteredByPrefix("zoo york")
        XCTAssert(results.count == 0)
    }
}
