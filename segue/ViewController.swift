//
//  ViewController.swift
//  segue
//
//  Created by masuda.shigeki on 2017/08/08.
//  Copyright © 2017年 masuda.shigeki. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var myCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "registration"){
            print("新規登録行きますわ")
            let nextView = segue.destination as! NextViewController
            nextView.userId = myCount + 1
        }
    }
    
    @IBAction func backToTop(segue: UIStoryboardSegue) {
    
    }


}

