//
//  Theme.swift
//  ThemeDemo
//
//  Created by Maxim Bystrov on 16.11.2019.
//  Copyright © 2019 Maxim Bystrov. All rights reserved.
//

import UIKit

protocol Theme: class {
    
    var backgroundColor: UIColor { get }
    var textColor: UIColor { get }
}


class DarkTheme: Theme {

    static let theme = DarkTheme()
    
    let backgroundColor: UIColor = .black
    let textColor: UIColor = .white
}


class LightTheme: Theme {
    
    static let theme = LightTheme()
    
    let backgroundColor: UIColor = .white
    let textColor: UIColor = .black
}
