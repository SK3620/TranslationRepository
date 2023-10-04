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
RealmSwift 10.20.0（＜List＞型で1対多を使用）  
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
Parchment ~> 3.0  
MessageKit  
RxSwift  

Installed in a terminal using CocoaPods  
# Features / Used Technologies  
#### 翻訳機能（非同期処理）  
#### https://github.com/SK3620/TranslationRepository/blob/main/TranslationApp/Controller/Contents%20Of%20TabBar/TranslateViewController/TranslateViewController.swift  
　・HTTP通信ライブラリAlmofireでDeeplAPIリクエスト  
　・ライブラリRxSwiftでイベント受け取り  
　・MVCを意識  
　・エラー処理にDoTryCatch文やResult＜Success, Failure＞型使用  
#### チュートリアル画面  
#### https://github.com/SK3620/TranslationRepository/blob/main/TranslationApp/Controller/Contents%20Of%20TabBar/TranslateViewController/TutorialViewController.swift  
　・StoryBoardなしでコーディングのみでUIレイアウトに挑戦  
　・CollectionView、カスタムなCollectionViewCell使用  
　・Cellに画像を使用  
#### 瞬間英作文が行える機能  
#### https://github.com/SK3620/TranslationRepository/blob/main/TranslationApp/Controller/Contents%20Of%20TabBar/FolderViewController/StudyViewController.swift  
　・ライブラリRealmSwiftの＜List＞型で１対多を使用  
　・xibでUITableViewCell使用  
　・ライブラリContextMenuSwift使用  
　・文字列絞り込み検索可能  
　・ライブラリSideMemu使用  
#### 学習記録機能  
#### https://github.com/SK3620/TranslationRepository/blob/main/TranslationApp/Controller/Contents%20Of%20TabBar/RecordViewController/RecordViewController.swift  
　・ライブラリFSCalendar使用  
　・ライブラリRealmSwift使用  
#### 翻訳履歴閲覧機能  
#### https://github.com/SK3620/TranslationRepository/blob/main/TranslationApp/Controller/Contents%20Of%20TabBar/HistoryViewController/HistoryViewContoller.swift  
　・ライブラリRealmSwift  
　・TableViewに入力テキスト、翻訳結果、翻訳日時を表示  
　・文字列絞り込み検索機能  
#### 単語やフレーズのお気に入り機能  
#### https://github.com/SK3620/TranslationRepository/tree/main/TranslationApp/Controller/Contents%20Of%20TabBar/PhraseWordViewController
　・ライブラリParchement使用
#### 簡易版SNS機能（ライブラリParchment使用）  
#### https://github.com/SK3620/TranslationRepository/tree/main/TranslationApp/Controller/Contents%20Of%20SecondTabBar  
　・ユーザー登録、ログイン、ログアウト  
　・プロフィール設定機能（プロフィール画像設定可）  
　・投稿機能（コメントも投稿可、画像投稿不可、フォロー機能なし）  
　・いいね機能  
　・ブックマーク機能  
　・ブロック、投稿内容通報機能  
　・投稿内容絞り込み検索機能（全文検索機能なし）  
　・投稿削除、コメント削除機能、アカウント削除機能  
  #### データの追加、削除、更新  
  　・DispatchQueueで複数非同期処理を直列/並列処理 → notifyでMainQueueへ
  #### チャット機能  
  #### https://github.com/SK3620/TranslationRepository/blob/main/TranslationApp/Controller/Contents%20Of%20SecondTabBar/SelfViewControllers/ChatRoomViewController.swift  
  　・ライブラリMessageKit使用  
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
（3つ目のデモビデオには、TwitterのようなシンプルなSNS機能。投稿、コメント、いいね！、ブックマーク、チャット、通報、ブロック機能などが含まれる。）  

https://user-images.githubusercontent.com/108386527/216686680-a577e982-f68e-4736-88d7-9c1342074929.mp4  
