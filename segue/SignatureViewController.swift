//
//  SignatureViewController.swift
//  KaoPass
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
    let photoLimit = 3 // 撮影枚数
    let photoInterval = 3.0 // 撮影間隔
    
    @IBOutlet weak var photoProgress: UIProgressView!
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
        
        let initialUrl = URL(string: "\(Settings.apiBaseUrl)/users/\(self.userId)/signatures/new")
        let request = URLRequest(url: initialUrl!)
        self.webView.loadRequest(request)
        self.webView.dataDetectorTypes = .link
    }

    override func viewWillAppear(_ animated: Bool) {        
        setupDisplay(hidden: true)
        setupCamera()
    }
    
    // 写真を撮影しサーバへポストする
    func takeStillPicture(){
        
        if var _:AVCaptureConnection? = output.connection(withMediaType: AVMediaTypeVideo){            
            if (photoLimit > photoCount){
                if true {
                    // アルバムに追加
                    // UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, nil, nil)
                    
                    let uploadUrl = URL(string: "\(Settings.apiBaseUrl)/api/users/\(self.userId)/photos")!
                    let params: [String: String] = ["access_token": "dummy"]
                    
                    let size = CGFloat(Settings.puloadImageSize)
                    let resizedImage = self.imageView.image?.convert(toSize:CGSize(width: ((self.imageView.image?.size.width)! * size), height:((self.imageView.image?.size.height)! * size)), scale: 1.0)
                    let imageData = UIImageJPEGRepresentation((resizedImage?.updateImageOrientionUpSide())! , 0.4)!
                    
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
            photoProgress.setProgress(Float(photoCount)/Float(photoLimit), animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.webView.delegate = nil
        self.photoTimer.invalidate()
        clearData()
    }
}
