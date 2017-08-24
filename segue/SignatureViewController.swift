//
//  NextViewController.swift
//  segue
//
//  Created by masuda.shigeki on 2017/08/08.
//  Copyright © 2017年 masuda.shigeki. All rights reserved.
//

import UIKit
import AVFoundation


class SignatureViewController: ImageViewBaseController, UIWebViewDelegate {
    
    var userId = 0

    var photoTimer = Timer()
    var photoCount = 0
    let photoLimit = 5
    let photoInterval = 5.0
    
    @IBOutlet weak var webView: UIWebView!
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if((webView.request?.url?.absoluteString)! == "\(Settings.apiBaseUrl)/users/\(userId)/signatures"){
            let naviView = self.storyboard!.instantiateViewController(withIdentifier: "session_navigation") as! UINavigationController
            let view = naviView.topViewController as! TimeTableViewController
            view.userId = self.userId
            self.present(naviView, animated: true, completion: nil)
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoTimer = Timer.scheduledTimer(timeInterval: photoInterval, target: self, selector: #selector(SignatureViewController.takeStillPicture), userInfo: nil, repeats: true)
        self.webView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let initialUrl = URL(string: "\(Settings.apiBaseUrl)/users/\(self.userId)/signatures/new")
        let request = URLRequest(url: initialUrl!)
        self.webView.loadRequest(request)
        self.webView.dataDetectorTypes = .link
        
        setupDisplay(hidden: true)
        setupCamera()
    }
    
    
    func takeStillPicture(){
        if var _:AVCaptureConnection? = output.connection(withMediaType: AVMediaTypeVideo){
            if (photoLimit >= photoCount){
                // アルバムに追加
                // UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, nil, nil)
                
                // Post
                // 画像アップロード先URL
                let uploadUrl = URL(string: "\(Settings.apiBaseUrl)/api/users/\(self.userId)/photos")!
                
                // params生成
                // access_token: Step.1で取得しているもの
                let params: [String: String] = ["access_token": "dummy"]
                
                // imageData生成
                let size = CGFloat(Settings.puloadImageSize)
                let resizedImage = self.imageView.image?.convert(toSize:CGSize(width: ((self.imageView.image?.size.width)! * size), height:((self.imageView.image?.size.height)! * size)), scale: 1.0)
                let imageData = UIImageJPEGRepresentation((resizedImage?.updateImageOrientionUpSide())! , 0.2)!
                
                // boudary生成
                let boundary = generateBoundaryString()
                var request = URLRequest(url: uploadUrl)
                request.httpMethod = "POST"
                request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.httpBody = createBodyWith(parameters: params, filePathKey: "photo[image]", imageData: imageData, boundary: boundary) as Data
                
                // 画像アップロードPOST
                urlSession.dataTask(with: request).resume()
                photoCount += 1
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.webView.delegate = nil
        self.photoTimer.invalidate()
        clearData()
    }
}
