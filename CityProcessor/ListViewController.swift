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

    fileprivate var filterOperationQueue = OperationQueue()

    fileprivate let collectionView = UICollectionView(
        frame: CGRect.zero,
        collectionViewLayout: UICollectionViewFlowLayout())
    fileprivate let searchController = UISearchController(searchResultsController: nil)

    fileprivate let mapVC = MapViewController()


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
        // A search for "París" should therefore return "Paris".
        let searchKey = searchController.searchBar.text!
            .folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive], locale: nil)

        guard searchKey != "" else {
            collectionView.reloadData()
            return
        }

        if filterOperationQueue.operationCount > 0 {
            // cancel current filtering operation if it's not done
            // yet and the user updated the search key
            filterOperationQueue.cancelAllOperations()
        }

        // Run filtering in the background
        let filterOperation = BlockOperation {
            self.filteredCityArray = self.cityArray.filteredByPrefix(searchKey)
        }

        filterOperation.completionBlock = {
            if !filterOperation.isCancelled {
                OperationQueue.main.addOperation {
                    self.collectionView.reloadData()
                }
            }
        }
        filterOperationQueue.addOperation(filterOperation)
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
