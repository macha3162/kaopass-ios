//
//  SearchViewController.swift
//  segue
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
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var message: UILabel!
    @IBAction func reEntry(_ sender: Any) {
        indicator.isHidden = false
        indicator.startAnimating()
        
        let result = searchFace()
        print(result.statusCode)
        print(result.json)
        switch result.statusCode {
        case 200:
            let nextView = self.storyboard!.instantiateViewController(withIdentifier: "do_enter") as! DoEnterViewController
            nextView.name = result.json["name"].stringValue
            nextView.sessionIds = result.json["session_ids"].arrayObject as! [Int]
            self.present(nextView, animated: true, completion: nil)
            self.readText(string: "\(result.json["name"].stringValue)さまは登録済みです。")
            self.readText(string: "\(result.json["visit_count"])回目の来場です")
            
        case 204:
            let nextView = self.storyboard!.instantiateViewController(withIdentifier: "do_not_enter") as! DoNotEnterViewController
            self.present(nextView, animated: true, completion: nil)
            self.readText(string: "登録を確認できませんでした")
        default:
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
            let resizedImage = self.imageView.image?.convert(toSize:CGSize(width: ((self.imageView.image?.size.width)! * size), height:((self.imageView.image?.size.height)! * size)), scale: 1.0)
            let imageData = UIImageJPEGRepresentation((resizedImage?.updateImageOrientionUpSide())! , 0.2)!
            
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
                                                //return (response.response?.statusCode, JSON(response.result.value!))
                                                //                                                let statusCode = response.response?.statusCode
                                                //                                                if statusCode == 200 {
                                                //                                                    let json = JSON(response.result.value!)
                                                //
                                                //                                                    self.readText(string: "こんにちは！\(json["name"].stringValue)さん")
                                                //                                                    self.readText(string: "\(json["visit_count"])回目の来場です")
                                                //                                                }else{
                                                //                                                    self.readText(string: "未登録です")
                                                //                                                }
                                                
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
    
    func readText(string: String) {
        while synthesizer.isSpeaking &&
            runLoop.run(mode: RunLoopMode.defaultRunLoopMode, before: NSDate(timeIntervalSinceNow: 0.1) as Date) {
                // 0.1秒毎の処理なので、処理が止まらない
                print("まち")
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // setupDisplay(hidden: false)
        let screenWidth = UIScreen.main.bounds.size.width/4;
        let screenHeight = UIScreen.main.bounds.size.height/4;
        
        // プレビュー用のビューを生成
        print("------------------")
        imageView = UIImageView()
        imageView.frame = CGRect(x: screenWidth * 3 - (screenWidth/2), y: (screenHeight * 2) - (screenHeight/2) - 50, width: screenWidth, height: screenHeight)
        imageView.layer.cornerRadius = self.imageView.frame.size.width / 2.0
        
        setupCamera()
        indicator.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clearData()
    }
}
