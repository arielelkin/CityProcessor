//
//  CollectionViewCell.swift
//  CityProcessor
//
//  Created by Ariel Elkin on 22/01/2018.
//  Copyright © 2018 Backbase. All rights reserved.
//

import UIKit

class CityCell: UICollectionViewCell {

    fileprivate let cityNameLabel = UILabel()
    fileprivate let countryNameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .white

        var viewsDict = [String: UIView]()

        cityNameLabel.textAlignment = .left
        cityNameLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        cityNameLabel.translatesAutoresizingMaskIntoConstraints = false
        viewsDict["cityNameLabel"] = cityNameLabel
        contentView.addSubview(cityNameLabel)

        countryNameLabel.textAlignment = .left
        countryNameLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        countryNameLabel.translatesAutoresizingMaskIntoConstraints = false
        viewsDict["countryNameLabel"] = countryNameLabel
        contentView.addSubview(countryNameLabel)

        let constraints = [
            "H:|-[cityNameLabel]-|",
            "H:|-[countryNameLabel]-|",
            "V:|-[cityNameLabel]-[countryNameLabel]",
            ].flatMap {
                NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: nil, views: viewsDict)
        }
        NSLayoutConstraint.activate(constraints)

    }
    var city: City? {
        didSet {
            cityNameLabel.text = city?.name
            countryNameLabel.text = city?.countryCode
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented because we're not using XIBs")
    }
}

