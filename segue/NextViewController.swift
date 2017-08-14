//
//  NextViewController.swift
//  segue
//
//  Created by masuda.shigeki on 2017/08/08.
//  Copyright © 2017年 masuda.shigeki. All rights reserved.
//

import UIKit

class NextViewController: UIViewController, UIWebViewDelegate {
    
    
    var userId = 0
    
    @IBOutlet weak var webView: UIWebView!
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        print("start!!")
        print(webView.request?.url?.absoluteString as! String)
        print("start")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        print(webView.request?.url?.absoluteString as! String)
        print("webViewDidFinishLoad")
        
        if((webView.request?.url?.absoluteString as! String) == "http://192.168.3.16:3000/users/\(userId)/signatures"){
            print("kita!!")
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "thank_you") as! FinalViewController
            self.present(nextView, animated: true, completion: nil)
        }
 
        
    }
    
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let initialUrl = URL(string: "http://192.168.3.16:3000/users/\(self.userId)/signatures/new")
        let request = URLRequest(url: initialUrl!)
        self.webView.loadRequest(request)
        self.webView.dataDetectorTypes = .link
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.webView.delegate = nil
        
    }
    
}

