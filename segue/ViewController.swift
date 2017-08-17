//
//  ViewController.swift
//  segue
//
//  Created by masuda.shigeki on 2017/08/08.
//  Copyright © 2017年 masuda.shigeki. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    var myCount = "0"

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
            
            let nextView = segue.destination as! SignatureViewController
            
            var keepAlive = true
            let runLoop = RunLoop.current
            
            Alamofire.request("\(Settings.apiBaseUrl)/api/users", method: .post).responseJSON {
                response in
                if response.result.isSuccess {
                    //まずJSONデータをNSDictionary型に
                    let jsonDic = response.result.value as! NSDictionary
                    //辞書化したjsonDicからキー値"responseData"を取り出す
                    print(jsonDic["id"] as! Int64)
                    print("とれるか")
                     nextView.userId = Int(jsonDic["id"] as! Int64)
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





