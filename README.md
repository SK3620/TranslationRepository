# Translation Repository  
Using the world's most powerful translation tool DeepL, it enables you to save the text to be translated and the translation results in the created folder.  
（世界で最も精巧な翻訳ツールDeepLを使用して、作成したフォルダに翻訳するテキストと翻訳結果を保存することができます。）  
# Description  
It is a App for instant English compositon training, which includes a listening feature, a learning record feature, a translation history viewing feature, a favorite registration feature, and a simple SNS feature that allows users to connect with each other.  
（リスニング機能、学習記録機能、翻訳履歴閲覧機能、お気に入り登録機能、ユーザー同士がつながる簡易SNS機能などを備えた、瞬間英作文トレーニングアプリです。）  
# URL / Installation
Compatible with IPhone only (iOS15.0 or later)  
https://apps.apple.com/jp/app/deepl%E7%BF%BB%E8%A8%B3%E4%BF%9D%E5%AD%98/id6443462724  
(You can download the application from this URL.)  
# Requirement  
Apple Swift version 5.7.1 (swiftlang-5.7.1.135.3 clang-1400.0.29.51)  
RealmSwift 10.20.0  
SVProgressHUD  
FSCalendar  
CalculateCalendarLogic  
ContextMenuSwift  
SideMenu ~> 6.0  
Firebase 8.9.1  
Firebase/Analytics   
Firebase/Auth  
Firebase/Firestore  
Firebase/Storage  
FirebaseUI/Storage  
CLImageEditor/AllTools 0.2.4  
SwiftFormat/CLI  
Parchment ~> 3.0  
MessageKit  
FirebaseDatabase  
RxSwift  
RxCocoa  

Installed in a terminal using CocoaPods
# Development Environment  
MacOS Monterey version 12.6 MacBook Pro (13-inch, 2019, Two Thunderbolt 3 ports)  
Xcode Version 14.1 (14B47b)  
# Author  
Name: Kenta Suzuki  
Email: (k-n-t1119@ezweb.ne.jp)  
Contact Information: https://tayori.com/form/7c23974951b748bcda08896854f1e7884439eb5c/  
# License  
There is no license for this program.  
(This program is published in a public repository, so GitHub users can view and fork it.)  
# Source Code Management Tools  
Git/GitHub  
Visual Studio Code (コードエディタ)   
SourceTree  
# Demo Video  
The first demo video includes the feature to save the sentences to be translated and the translation results, the listening feature and other features.↓  
（最初のデモビデオには、翻訳する文章と翻訳結果を保存する機能、リスニング機能などが含まれる。）  

https://github.com/SK3620/TranslationRepository/assets/108386527/8479c79d-cea1-4e72-976c-178b83cb9ab3  

The second demo video includes the study record feature.↓  
（二つ目のデモビデオには、学習記録機能が含まれる。）  

https://github.com/SK3620/TranslationRepository/assets/108386527/86dcd168-2c8c-439e-bcdf-84072e2722bb  

The third demo video includes a simple SNS feature like Twitter. It has posting, commenting, liking, bookmarking, chatting, reporting, blocking feature, etc.↓  
（3つ目のデモ動画は、TwitterのようなシンプルなSNS機能。投稿、コメント、いいね！、ブックマーク、チャット、通報、ブロック機能などがあります。）  

https://user-images.githubusercontent.com/108386527/216686680-a577e982-f68e-4736-88d7-9c1342074929.mp4  
# Overall issues, points to be corrected, future measures about this app for users (Japanese) 
##### 課題1 (version1.2, 1.3にて解決済み)  
StudyViewController, PhraseWordViewController画面のデザイン・UIが好ましくない。  
##### 解決策  
indexPath.rowごとに、テキストとテキストの間隔に統一感がなく、空白があるため、CustomCell上のUI部品のレイアウト修正が必要。  
全体的にテキストが凝縮されている感じがあり、indexPath.rowごとに区別がつきやすいデザインにする必要。  
##### 課題2  
このアプリ機能の一つである、ユーザー同士で繋がれるfirebaseを活用した簡易版SNS機能の利用者数が0人。  
原因としては、企画段階で「簡易版SNS機能を利用することでユーザーが得られるメリット」について十分に検討できておらず、主観的情報による開発を進めていたため、ユーザー目線に立てていなかったこと。  
（企画段階ではSNS機能を利用してユーザー同士で英語に関する情報交換や教え合いなどが行えるようにすることで、ユーザーの英語学習に対するモチベーション向上などをメリットとして提供できると考えていた。しかし、それらはTwitterやHelloTalkなどで既に実現されている上、機能も似ており、まったく差別化できていない）  
##### 解決策  
模索中...  
##### 課題3  
音声再生機能が不十分である。  
##### 解決策  
3秒、5秒巻き戻しと早送り機能の実装。参考URL:https://nackpan.net/blog/blog/2020/02/15/play-movie-avplayerlayer-skip-seek/  
# Overall issues, points to be corrected, future measures about source code (Japanese)   
#### 就活準備のため、swiftファイルが多く修正すべき箇所が非常に多いが故に修正にかなりの時間を要するため、就活後の修正作業に向けて、今後の課題、修正すべき箇所を記述しておく。  

##### 課題1  
Extensionを利用せずに、カスタムcell上のUIButtonなどをaddTarget()を利用してイベント処理を記述しているため、コードの可読性が低下している。  
##### 解決策  
カスタムcell上のUIButtonなどは、カスタムcell内にAction接続し、タップ時に呼び出されるデリゲートメソッドを定義する。viewController側からの呼び出し時は、extension HogeViewController: CustomCellButtonTappedDelegate { タップ時の処理 } のように記述することで、コードの可読性が向上する。  
##### 課題2  
Segueの多用によって、storyboardが見づらくなる可能性がある。また、iOSアプリ開発の実務経験6年のメンターから、開発現場ではsegueはあまり使用せず、コードのみの画面遷移が基本であるとご指摘をいただいた。    
##### 解決策  
navigationController.pushViewControllerメソッドを利用して、コードのみでの画面遷移を心がける。  
*例 let hogeViewController = self.storyboard?.instantiateViewController(withIdentifier: "Test") as! HogeViewController  
self.navigationController?.pushViewController(hogeViewController, animated: true)*  
##### 課題3  
オブジェクト指向をあまり意識できていないため、コードが肥大化し、可読性が低下している。いいね機能、ブックマーク機能、データ削除など、タップ時のFirebaseDatabaseやRealmへのデータ操作処理を大量のviewControllerに直接記述している。  
##### 解決策  
コードの見通しをよくするために、役割や機能ごとに処理を分ける必要がある。  
FirebaseDatabaseへのデータ更新処理を行う専用の構造体をModelクラスとして作成することで、可読性を向上させる。  
*例  
Struct updateData {  
    static func updateLikes(・・・){  
              FirebaseDatabaseへのデータ更新処理  
     }  
    static func updateBookMarks(・・・){  
              FirebaseDatabaseへのデータ更新処理  
     }  
}*  
##### 課題4  
一つのstoryBoardに含まれるviewControllerの数が少し多すぎるため、複数人による開発の際、互いにstoryboardをいじるとコンフリクトが生じる可能性がある。  
##### 解決策  
複数人で開発を行う場合には、  
・機能ごとにStoryboardを分ける  
・1ViewController,1storyboardに分ける  
・storyboardを使わず、xibを使って開発を行う  
今回は機能ごとにstoryboardを分割したが、一つのstoryBoardに含まれるviewControllerの数が少し多い。もう少し、機能ごとにstoryboardを分割していく必要がある。  
##### 課題5  
Extensionを積極的に活用していないため、コードの可読性が低下している。  
*例 HogeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomCellButtonTappedDelegate {}*  
##### 解決策  
Extension HogeViewController: UITableViewDelegate, UITableViewDataSource {}  
Extension HogeViewController: CustomCellButtonTappedDelegate {}  
と記述することでコードの可読性を向上させる。  
##### 課題6  
適切なアクセス修飾子がつけられていないため、開発時に誤って想定外のところでアクセス、呼び出してしまう可能性がある。  
##### 解決策  
新たにプロパティやメソッドなどの記述する際には、別の場所からアクセスしない限りは、とりあえず全てprivateと記述しておいた方が良い。  
##### 課題7  
開発初期時は、ただ、「機能すれば良い」というスタンスで闇雲にコードを書いていたため、可読性が非常に低い箇所が多数ある。  
##### 解決策  
保守性を意識したコードを書く必要がある。  
1. 変数名やメソッド名は分かりやすい名前を書く。  
2. コメントはできる限りわかりやすく、無駄なものは書かない。  
3. マジックナンバーは使わない。 変数を利用する。  
4. ネストは深くしすぎない。 深くても２つまで。  
5. インデントをしっかりつける。  
6. プログラムは上から下に処理が流れるように記述する。　など  





 



