//
//  ListViewController.swift
//  CityProcessor
//
//  Created by Ariel Elkin on 22/01/2018.
//  Copyright © 2018 Backbase. All rights reserved.
//



import UIKit

class ListViewController: UIViewController {

    let cityArray: [City]

    init(cityArray: [City]) {
        self.cityArray = cityArray
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .orange

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented because we're not using XIBs")
    }
}
