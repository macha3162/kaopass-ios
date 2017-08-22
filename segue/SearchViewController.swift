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
    
    @IBOutlet weak var messageLabel: UILabel!
    let synthesizer = AVSpeechSynthesizer()
    let runLoop = RunLoop.current
    
    
    @IBAction func reEntry(_ sender: Any) {
        takeStillPicture()
    }
    
    func takeStillPicture(){
        if var _:AVCaptureConnection? = output.connection(withMediaType: AVMediaTypeVideo){
            
            // アルバムに追加
            // UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, nil, nil)
            
            
            // imageData生成
            //let resizedImage = self.imageView.image?.convert(toSize:CGSize(width:600.0, height:800.0), scale: 1.0)
            let resizedImage = self.imageView.image?.convert(toSize:CGSize(width:300.0, height:400.0), scale: 1.0)
            let imageData = UIImageJPEGRepresentation((resizedImage?.updateImageOrientionUpSide())! , 0.1)!
            
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
                                                let statusCode = response.response?.statusCode
                                                print(statusCode as Any)
                                                if statusCode == 200 {
                                                    let json = JSON(response.result.value!)
                                                    print(json["id"])
                                                    
                                                    self.readText(string: "こんにちは！\(json["name"].stringValue)さん")
                                                    self.readText(string: "\(json["visit_count"])回目の来場です")
                                                }else{
                                                    self.readText(string: "未登録です")
                                                }
                                                
                                            }else{
                                                self.readText(string: "顔が検出できませんでした")
                                            }
                               
                                            
                                    }
                                case .failure(let encodingError):
                                    print(encodingError)
                                }
            })
        }
    }
    
    func readText(string: String) {
        
        while synthesizer.isSpeaking &&
            runLoop.run(mode: RunLoopMode.defaultRunLoopMode, before: NSDate(timeIntervalSinceNow: 0.1) as Date) {
        
                // 0.1秒毎の処理なので、処理が止まらない
                print("まち")
        }
        print(string)
        print("-------------------")
        messageLabel.text = string
        let utterWords = AVSpeechUtterance(string: string)
        utterWords.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        synthesizer.speak(utterWords)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        setupDisplay()
        setupCamera()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clearData()
        print("呼ばれた")
    }
}
