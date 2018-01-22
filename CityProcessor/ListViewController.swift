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

    fileprivate let kCellReuseIdentifier = "cell"

    init(cityArray: [City]) {
        self.cityArray = cityArray
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        //todo:
        //         navigationItem.searchController = searchController //local instance
        //        navigationItem.largeTitleDisplayMode = .never

    }

    fileprivate func setupUI() {

        view.backgroundColor = .lightGray

        title = "Cities"
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.hidesSearchBarWhenScrolling = false
        }

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented because we're not using XIBs")
    }
}

extension ListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("tapped \(indexPath)")
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 10)
    }
}

extension ListViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cityArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellReuseIdentifier, for: indexPath) as! CityCell
        cell.city = cityArray[indexPath.item]
        return cell
    }
}
