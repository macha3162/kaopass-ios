//
//  SearchViewController.swift
//  KaoPass
//
//  Created by masuda.shigeki on 2017/08/08.
//  Copyright © 2017年 masuda.shigeki. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import SwiftyJSON

class SearchViewController: ImageViewBaseController {
    
    let synthesizer = AVSpeechSynthesizer()
    let runLoop = RunLoop.current
    var faceCheckTimer = Timer()
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var message: UILabel!
    @IBAction func reEntry(_ sender: Any) {
        indicator.isHidden = false
        indicator.startAnimating()
        
        if faceCount() > 0 {
            let result = searchFace()
            print(result.statusCode)
            switch result.statusCode {
            case 200:
                let nextView = self.storyboard!.instantiateViewController(withIdentifier: "do_enter") as! DoEnterViewController
                nextView.name = result.json["name"].stringValue
                nextView.sessionIds = result.json["session_ids"].arrayObject as! [Int]
                self.present(nextView, animated: true, completion: nil)
                self.readText(string: "\(result.json["name"].stringValue)さまは、登録済みです。")
                self.readText(string: "\(result.json["visit_count"])回目の来場です。")
                
            case 204:
                let nextView = self.storyboard!.instantiateViewController(withIdentifier: "do_not_enter") as! DoNotEnterViewController
                self.present(nextView, animated: true, completion: nil)
                self.readText(string: "登録を確認できませんでした")
            default:
                self.readText(string: "顔が検出できませんでした")
            }
        }else{
            self.readText(string: "顔が検出できませんでした")
        }
        
        indicator.stopAnimating()
        indicator.isHidden = true
    }
    
    func searchFace() -> (statusCode: Int,json: JSON){
        var statusCode = 0
        var resultJson = JSON([""])
        
        
        if var _:AVCaptureConnection? = output.connection(withMediaType: AVMediaTypeVideo){
            
            // アルバムに追加
            // UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, nil, nil)
            
            // imageData生成
            let size = CGFloat(Settings.searchImageSize)
            let resizedImage = self.imageView.image?.convert(toSize:CGSize(width: ((self.imageView.image?.size.width)! * size),
                                                                           height: ((self.imageView.image?.size.height)! * size)), scale: 1.0)
            let imageData = UIImageJPEGRepresentation((resizedImage?.updateImageOrientionUpSide())! , 0.4)!
            
            var keepAlive = true
            let runLoop = RunLoop.current
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(imageData,
                                         withName: "search[image]",
                                         fileName: "search.jpg",
                                         mimeType: "multipart/form-data")},
                             to: URL(string: "\(Settings.apiBaseUrl)/api/searches")!,
                             encodingCompletion: { encodingResult in
                                // file をエンコードした後のコールバック
                                switch encodingResult {
                                case .success(let upload, _, _):
                                    upload
                                        .uploadProgress(closure: { (progress) in
                                            print("Upload Progress: \(progress.fractionCompleted)")
                                        })
                                        .responseJSON { response in
                                            if response.result.isSuccess {
                                                statusCode = (response.response?.statusCode)!
                                                resultJson = JSON(response.result.value!)
                                                
                                            }
                                            keepAlive = false
                                    }
                                case .failure(let encodingError):
                                    print(encodingError)
                                    keepAlive = false
                                }
            })
            
            while keepAlive &&
                runLoop.run(mode: RunLoopMode.defaultRunLoopMode, before: NSDate(timeIntervalSinceNow: 0.1) as Date) {
            }
        }
        return (statusCode, resultJson)
    }
    
    // 引数の文字列を日本語音声で読み上げる.
    func readText(string: String) {
        // 読み上げが空振りしないように待つ.
        while synthesizer.isSpeaking &&
            runLoop.run(mode: RunLoopMode.defaultRunLoopMode, before: NSDate(timeIntervalSinceNow: 0.1) as Date) {
                print("waiting.")
        }
        print(string)
        print("-------------------")
        message.text = string
        let utterWords = AVSpeechUtterance(string: string)
        utterWords.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        synthesizer.speak(utterWords)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenWidth = UIScreen.main.bounds.size.width/4;
        let screenHeight = UIScreen.main.bounds.size.height/4;
        let imageWidth: CGFloat = 480.0/3.0
        let imageHeight: CGFloat = 640.0/3.0
        
        // プレビュー用のビューを生成
        imageView = UIImageView()
        imageView.frame = CGRect(x: screenWidth * 3 - (imageHeight/2), y: (screenHeight * 2) - (imageWidth/2) - 50, width: imageHeight, height: imageWidth)
        imageView.layer.borderWidth = 1
        faceCheckTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.faceCheck), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupCamera()
        indicator.isHidden = true
        faceCheck()
    }
    
    func faceCheck(){
        if(faceCount() > 0){
            imageView.layer.borderColor = UIColor.green.cgColor
        } else{
            imageView.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clearData()
        faceCheckTimer.invalidate()
    }
}
