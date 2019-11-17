//
//  ViewController.swift
//  ThemeDemo
//
//  Created by Maxim Bystrov on 16.11.2019.
//  Copyright © 2019 Maxim Bystrov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let vc2 = ViewController2()
        addChild(vc2)
        view.addSubview(vc2.view)
        vc2.didMove(toParent: self)
    }


}


class ViewController2: UIViewController {
    
    var observation: NSKeyValueObservation?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        observation = observe(
            \.parent,
            options: [.initial, .new]
        ) { object, change in
            print("parent updated to: \(change.newValue)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

