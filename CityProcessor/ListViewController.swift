//
//  ListViewController.swift
//  CityProcessor
//
//  Created by Ariel Elkin on 22/01/2018.
//  Copyright © 2018 Backbase. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    private let cityArray: [City]
    fileprivate var filteredCityArray = [City]()

    fileprivate let kCellReuseIdentifier = "cell"

    let collectionView = UICollectionView(
        frame: CGRect.zero,
        collectionViewLayout: UICollectionViewFlowLayout())
    let searchController = UISearchController(searchResultsController: nil)

    let mapVC = MapViewController()


    init(cityArray: [City]) {
        self.cityArray = cityArray
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    fileprivate func setupUI() {

        title = "Cities"

        view.backgroundColor = .white

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController


        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Please enter search term"
        definesPresentationContext = true

        collectionView.backgroundColor = .lightGray
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CityCell.self, forCellWithReuseIdentifier: kCellReuseIdentifier)
        collectionView.delaysContentTouches = false
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        
        let constraints = [
            "H:|[collectionView]|",
            "V:|[collectionView]|",
            ].flatMap {
                NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: nil, views: ["collectionView": collectionView])
        }
        NSLayoutConstraint.activate(constraints)
    }

    fileprivate var isFiltering: Bool {
        return searchController.isActive &&
            searchController.searchBar.text != ""
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented because we're not using XIBs")
    }
}

extension ListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {

        // Accomodate entries not in English. For example:
        // Paris, the French capital, is spelt "París in Spanish.
        // A search for "París" should return "Paris".
        let searchKey = searchController.searchBar.text!.folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive], locale: nil)

        guard searchKey != "" else {
            collectionView.reloadData()
            return
        }

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

         Currently, a search is ran on the fully cityArray every time
         a character is added or removed from the search bar. This could
         be optimised by running a search on the filtered array.

         Similarly, we're calling reloadData() on the collection view every
         time a character is added or removed from the search bar. This could be
         optimised by manually adding or removing cells from the collection view.

         The two linear searches following the binary search happen sequentially.
         They could instead each be wrapped into Operations and run in parallel.

         */

        filteredCityArray = [City]()

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

        collectionView.reloadData()
    }
}


func binarySearch(_ array: [City], key: String, range: Range<Int>) -> Int? {

    if range.lowerBound >= range.upperBound {
        // If we get here, then the search key is not present in the array.
        return nil

    } else {
        // Calculate where to split the array.
        let midIndex = range.lowerBound + (range.upperBound - range.lowerBound) / 2

        if array[midIndex].name.lowercased().hasPrefix(key) {
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
extension ListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(mapVC, animated: true)
        if isFiltering {
            mapVC.city = filteredCityArray[indexPath.item]
        }
        else {
            mapVC.city = cityArray[indexPath.item]
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 10)
    }
}

extension ListViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering {
            return filteredCityArray.count
        }
        else {
            return cityArray.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellReuseIdentifier, for: indexPath) as! CityCell

        if isFiltering {
            cell.city = filteredCityArray[indexPath.item]
        }
        else {
            cell.city = cityArray[indexPath.item]
        }
        return cell
    }
}
