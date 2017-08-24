//
//  ViewController.swift
//  segue
//
//  Created by masuda.shigeki on 2017/08/08.
//  Copyright © 2017年 masuda.shigeki. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TopViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "start_registration"){
            let nextView = segue.destination as! SignatureViewController
            
            var keepAlive = true
            let runLoop = RunLoop.current
            
            Alamofire.request("\(Settings.apiBaseUrl)/api/users", method: .post).responseJSON {
                response in
                if response.result.isSuccess {
                    let json = JSON(response.result.value!)
                     nextView.userId = json["id"].int!
                }
                keepAlive = false
            }
            while keepAlive &&
                runLoop.run(mode: RunLoopMode.defaultRunLoopMode, before: NSDate(timeIntervalSinceNow: 0.1) as Date) {
                    // 0.1秒毎の処理なので、処理が止まらない
            }
            
        }
    }
    
    @IBAction func backToTop(segue: UIStoryboardSegue) {
    
    }
}
