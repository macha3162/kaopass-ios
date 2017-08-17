//
//  SearchViewController.swift
//  segue
//
//  Created by masuda.shigeki on 2017/08/08.
//  Copyright © 2017年 masuda.shigeki. All rights reserved.
//

import UIKit

class SearchViewController: ImageViewBaseController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        setupDisplay()
        setupCamera()
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clearData()
        print("呼ばれた")
    }
}
