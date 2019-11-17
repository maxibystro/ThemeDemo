//
//  ThemeEnvironment.swift
//  ThemeDemo
//
//  Created by Maxim Bystrov on 16.11.2019.
//  Copyright © 2019 Maxim Bystrov. All rights reserved.
//

import Foundation

protocol ThemeEnvironment {
    
    var theme: Theme { get }
    
    func themeDidChange()
}
