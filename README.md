# KaoPass

イベントのチェックインを、手書き認識と顔認証でおこなえるようにしたiOSアプリです。  
実行するためには、このアプリとKaoPassの[バックエンド](https://github.com/macha3162/kaopass-backend)を実行する必要があります。  

### アプリケーションの概要


操作はiOSアプリで行います。  
アプリの動画は[こちら](https://vimeo.com/232448592)からご覧になれます。

#### イベント新規登録
iPadまたはiPhoneの画面に手書きで名前を入力し、次に興味のあるセッションを選びます。  
なんとそれだけ！以上でチェックインは完了です。

![KaoPass新規登録](https://media.giphy.com/media/6ekYTjQ5Gx4D6/giphy.gif "新規登録")



#### イベント再入場
顔写真を撮影すると顔の分析を行います。  
イベント登録のあったユーザは、手書き入力された名前を読み上げつつ、選んだセッションが表示されます。  
登録のない人は、入場禁止画面が表示されます。

![KaoPass再入場](https://media.giphy.com/media/DqWgTaUIAbv4A/giphy.gif "再入場")


### バックエンド
どのセッションにどれだけ申し込みがあるのか、どの時間帯に入場が多かったのか等を表示するダッシュボード画面があります。  
この画面は申し込みがある度に、自動で更新されるようになっています。RailsのActionCableを使って実現しています。  
また、アプリ側に表示されるイベント情報を編集することが出来ます。


## 動作環境/必要なもの
* iOS 10以降

## ビルド方法
### CoocaPods

CocoaPodsが必要です。

```
pod install
```

実行後に KaoPass.xcworkspace を開いてください。

## バックエンドの設定

Settings.swift に通信先のサーバ情報がかかれています。  
バックエンドの環境のアドレスを指定してください。


```
struct Settings {
    // KaoPassAPIのURLを設定する.
    static let apiBaseUrl = "http://192.168.1.2:3000"
}
```


カメラを利用するため実機で動作確認を行ってください。


## バックエンドへの接続

アプリを立ち上げるとバックエンドと通信を行います。
KaoPassアプリのバックエンドリポジトリは[こちら](https://github.com/macha3162/kaopass-backend)。

## お問い合わせ

何か不明な点があれば、[@macha3162](https://twitter.com/macha3162)までご連絡ください。


## License
[Supported by Synergy Marketing, Inc.](https://synergist.jp/)
Licensed under [MIT](LICENSE).
