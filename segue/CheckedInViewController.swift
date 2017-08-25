//
//  FinalViewController.swift
//  segue
//
//  Created by masuda.shigeki on 2017/08/08.
//  Copyright © 2017年 masuda.shigeki. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CheckedInViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
