//
//  NextViewController.swift
//  segue
//
//  Created by masuda.shigeki on 2017/08/08.
//  Copyright © 2017年 masuda.shigeki. All rights reserved.
//

import UIKit
import AVFoundation


class NextViewController: UIViewController, UIWebViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var userId = 0
    var input:AVCaptureDeviceInput!
    var output:AVCaptureVideoDataOutput!
    var session:AVCaptureSession!
    var camera:AVCaptureDevice!
    var imageView:UIImageView!
    
    var photoTimer = Timer()
    var photoCount = 0
    let photoLimit = 5
    let urlSession = URLSession.shared
    let mimetype = "image/jpeg"
    let CRLF = "\r\n"
    let photoInterval = 5.0
    
    @IBOutlet weak var webView: UIWebView!
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        print("start!!")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        print("webViewDidFinishLoad")
        
        if((webView.request?.url?.absoluteString)! == "\(Settings.apiBaseUrl)/users/\(userId)/signatures"){
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
        
        photoTimer = Timer.scheduledTimer(timeInterval: photoInterval, target: self, selector: #selector(NextViewController.takeStillPicture), userInfo: nil, repeats: true)
        self.webView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let initialUrl = URL(string: "\(Settings.apiBaseUrl)/users/\(self.userId)/signatures/new")
        let request = URLRequest(url: initialUrl!)
        self.webView.loadRequest(request)
        self.webView.dataDetectorTypes = .link
        
        setupDisplay()
        setupCamera()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.webView.delegate = nil
        
        session.stopRunning()
        
        for output in session.outputs {
            session.removeOutput(output as? AVCaptureOutput)
        }
        
        for input in session.inputs {
            session.removeInput(input as? AVCaptureInput)
        }
        photoTimer.invalidate()
        session = nil
        camera = nil
        
    }
    func setupDisplay(){
        //スクリーンの幅
        let screenWidth = UIScreen.main.bounds.size.width/4;
        //スクリーンの高さ
        let screenHeight = UIScreen.main.bounds.size.height/4;
        
        // プレビュー用のビューを生成
        imageView = UIImageView()
        imageView.frame = CGRect(x: UIScreen.main.bounds.size.width - screenWidth, y: 0.0, width: screenWidth, height: screenHeight)
    }
    
    func setupCamera(){
        // AVCaptureSession: キャプチャに関する入力と出力の管理
        session = AVCaptureSession()
        
        // sessionPreset: キャプチャ・クオリティの設定
        session.sessionPreset = AVCaptureSessionPresetHigh
        //        session.sessionPreset = AVCaptureSessionPresetPhoto
        //        session.sessionPreset = AVCaptureSessionPresetHigh
        //        session.sessionPreset = AVCaptureSessionPresetMedium
        //        session.sessionPreset = AVCaptureSessionPresetLow
        
        
        
        // 背面・前面カメラの選択 iOS10での変更
        camera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera,
                                               mediaType: AVMediaTypeVideo,
                                               position: .front) // position: .front
        
        
        // カメラからの入力データ
        do {
            input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
        } catch let error as NSError {
            print(error)
        }
        
        
        // 入力をセッションに追加
        if(session.canAddInput(input)) {
            session.addInput(input)
        }
        
        output = AVCaptureVideoDataOutput()
        // 出力をセッションに追加
        if(session.canAddOutput(output)) {
            session.addOutput(output)
        }
        
        // ピクセルフォーマットを 32bit BGR + A とする
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : Int(kCVPixelFormatType_32BGRA)]
        
        // フレームをキャプチャするためのサブスレッド用のシリアルキューを用意
        output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        output.alwaysDiscardsLateVideoFrames = true
        
        // ビデオ出力に接続
        //        let connection  = output.connection(withMediaType: AVMediaTypeVideo)
        
        session.startRunning()
        
        // deviceをロックして設定
        // swift 2.0
        do {
            try camera.lockForConfiguration()
            // フレームレート
            camera.activeVideoMinFrameDuration = CMTimeMake(1, 30)
            
            camera.unlockForConfiguration()
        } catch _ {
        }
    }
    
    
    // 新しいキャプチャの追加で呼ばれる
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        // キャプチャしたsampleBufferからUIImageを作成
        let image:UIImage = self.captureImage(sampleBuffer)
        
        // 画像を画面に表示
        DispatchQueue.main.async {
            self.imageView.image = image
            
            // UIImageViewをビューに追加
            self.view.addSubview(self.imageView)
        }
    }
    
    // sampleBufferからUIImageを作成
    func captureImage(_ sampleBuffer:CMSampleBuffer) -> UIImage{
        
        // Sampling Bufferから画像を取得
        let imageBuffer:CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        // pixel buffer のベースアドレスをロック
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        let baseAddress:UnsafeMutableRawPointer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)!
        
        let bytesPerRow:Int = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width:Int = CVPixelBufferGetWidth(imageBuffer)
        let height:Int = CVPixelBufferGetHeight(imageBuffer)
        
        
        // 色空間
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        
        //let bitsPerCompornent:Int = 8
        // swift 2.0
        let newContext:CGContext = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace,  bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue|CGBitmapInfo.byteOrder32Little.rawValue)!
        
        let imageRef:CGImage = newContext.makeImage()!
        let resultImage = UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImageOrientation.right)
        
        return resultImage
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
                
                
                let resizedImage = self.imageView.image?.convert(toSize:CGSize(width:600.0, height:800.0), scale: 1.0)
                let imageData = UIImageJPEGRepresentation((resizedImage?.updateImageOrientionUpSide())! , 0.1)!
                
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
    
    // Create body for media
    func createBodyWith(parameters: [String: String]?, filePathKey: String?, imageData: Data, boundary: String) -> NSData {
        let body = NSMutableData()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                body.appendString(string:"--\(boundary)" + CRLF)
                body.appendString(string:"Content-Disposition: form-data; name=\"\(key)\"" + CRLF + CRLF)
                body.appendString(string:"\(value)" + CRLF)
            }
        }
        
        body.appendString(string:"--\(boundary)\r\n")
        body.appendString(string:"Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"iphone.jpg\"" + CRLF)
        body.appendString(string:"Content-Type: \(mimetype)" + CRLF + CRLF)
        body.append(imageData)
        body.appendString(string: CRLF)
        body.appendString(string:"--\(boundary)--" + CRLF)
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func resizeUIImageByWidth(image: UIImage, width: Double) -> UIImage {
        // オリジナル画像のサイズから、アスペクト比を計算
        let aspectRate = image.size.height / image.size.width
        // リサイズ後のWidthをアスペクト比を元に、リサイズ後のサイズを取得
        let resizedSize = CGSize(width: width, height: width * Double(aspectRate))
        // リサイズ後のUIImageを生成して返却
        UIGraphicsBeginImageContext(resizedSize)
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
}

// Image extension
extension UIImage {
    
    func updateImageOrientionUpSide() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        }
        UIGraphicsEndImageContext()
        return nil
    }
    
    func convert(toSize size:CGSize, scale:CGFloat) ->UIImage
    {
        let imgRect = CGRect(origin: CGPoint(x:0.0, y:0.0), size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        self.draw(in: imgRect)
        let copied = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return copied!
    }
}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}



