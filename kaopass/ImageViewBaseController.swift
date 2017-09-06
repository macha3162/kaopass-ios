//
//  ImageViewBaseController.swift
//  KaoPass
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
    
    func setupDisplay(hidden: Bool){
        let imageWidth: CGFloat = 640.0/3.0
        let imageHeight: CGFloat = 480.0/3.0
        
        
        // プレビュー用のビューを生成
        imageView = UIImageView()
        imageView.frame = CGRect(x: UIScreen.main.bounds.size.width - imageWidth, y: UIScreen.main.bounds.size.height - imageHeight, width: imageWidth, height: imageHeight)
        imageView.isHidden = hidden
    }
    
    // カメラをセットアップする
    func setupCamera(){
        session = AVCaptureSession()
        
        // sessionPreset: キャプチャ・クオリティの設定
        session.sessionPreset = AVCaptureSessionPreset640x480
        //        session.sessionPreset = AVCaptureSessionPresetPhoto
        //        session.sessionPreset = AVCaptureSessionPresetHigh
        //        session.sessionPreset = AVCaptureSessionPresetMedium
        //        session.sessionPreset = AVCaptureSessionPresetLow
        
        // 背面・前面カメラの選択
        camera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera,
                                               mediaType: AVMediaTypeVideo,
                                               position: .front)
        
        
        // カメラからの入力データ
        do {
            input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
        } catch let error as NSError {
            print(error)
        }
        
        
        if(session.canAddInput(input)) {
            session.addInput(input)
        }
        
        output = AVCaptureVideoDataOutput()
        if(session.canAddOutput(output)) {
            session.addOutput(output)
        }
        
        output?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : Int(kCVPixelFormatType_32BGRA)]
        output?.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        // キューのブロック中に新しいフレームが来たら削除する
        output?.alwaysDiscardsLateVideoFrames = true
        session.startRunning()
        
        // deviceをロックして設定
        do {
            try camera.lockForConfiguration()
            camera.activeVideoMinFrameDuration = CMTimeMake(1, 10)
            camera.unlockForConfiguration()
        } catch _ {
        }
    }
    
    // 画像の中にふくまれる顔の数を返す.
    func faceCount() -> Int {
        if let cgImage = self.imageView.image?.cgImage {
            let ciImage = CIImage(cgImage: cgImage)
            
            // 顔認識なのでTypeをCIDetectorTypeFaceに指定する
            let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
            let features = detector?.features(in: ciImage)
            
            var resultString = ""
            resultString.append("features: count\(String(describing: features?.count))\n" )
            for feature in features as! [CIFaceFeature] {
                resultString.append("bounds: \(NSStringFromCGRect(feature.bounds))\n")
                resultString.append("\n")
            }
            print(resultString)
            
            return (features?.count)!
        }else{
            return 0
        }
    }
    
    
    // 新しいキャプチャの追加で呼ばれる
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
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
        let imageBuffer:CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        let baseAddress:UnsafeMutableRawPointer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)!
        
        let bytesPerRow:Int = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width:Int = CVPixelBufferGetWidth(imageBuffer)
        let height:Int = CVPixelBufferGetHeight(imageBuffer)
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let newContext:CGContext = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace,  bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue|CGBitmapInfo.byteOrder32Little.rawValue)!
        
        let imageRef:CGImage = newContext.makeImage()!
        let orientation = (UIDevice.current.orientation == UIDeviceOrientation.landscapeRight) ? UIImageOrientation.upMirrored : UIImageOrientation.downMirrored
        let resultImage = UIImage(cgImage: imageRef, scale: 1.0, orientation: orientation)
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
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
    
    // 画像をアスペクト比を保ちつつリサイズする
    func resizeUIImageByWidth(image: UIImage, width: Double) -> UIImage {
        let aspectRate = image.size.height / image.size.width
        let resizedSize = CGSize(width: width, height: width * Double(aspectRate))
        UIGraphicsBeginImageContext(resizedSize)
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.height, height: resizedSize.width))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    func clearData(){
        if session != nil{
            session.stopRunning()
            for output in session.outputs {
                session.removeOutput(output as? AVCaptureOutput)
            }
            
            for input in session.inputs {
                session.removeInput(input as? AVCaptureInput)
            }
        }
        session = nil
        camera = nil
        imageView = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

