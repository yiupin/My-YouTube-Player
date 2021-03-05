//
//  CustomNavigationController.swift
//  My YouTube Player
//
//  Created by Pin Yiu on 7/2/2021.
//  Copyright © 2021 Pin Yiu. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    override var shouldAutorotate: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barTintColor = .black
        navigationBar.tintColor = .white
        
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
    }
    
}
