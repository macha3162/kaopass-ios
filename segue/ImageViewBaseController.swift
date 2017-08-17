//
//  ImageViewBaseController.swift
//  segue
//
//  Created by masuda.shigeki on 2017/08/17.
//  Copyright © 2017年 masuda.shigeki. All rights reserved.
//

import UIKit
import AVFoundation

class ImageViewBaseController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var input:AVCaptureDeviceInput!
    var output:AVCaptureVideoDataOutput!
    var session:AVCaptureSession!
    var camera:AVCaptureDevice!
    var imageView:UIImageView!
    let urlSession = URLSession.shared
    
    let mimetype = "image/jpeg"
    let CRLF = "\r\n"
    
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
            // 画像を反転
            self.imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            
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
    
    func clearData(){
        session.stopRunning()
        
        for output in session.outputs {
            session.removeOutput(output as? AVCaptureOutput)
        }
        
        for input in session.inputs {
            session.removeInput(input as? AVCaptureInput)
        }
        session = nil
        camera = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
