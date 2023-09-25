//
//  TranslateViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/27.
//

import Alamofire
import AVFoundation
import ContextMenuSwift
import RealmSwift
import RxCocoa
import RxSwift
import SVProgressHUD
import UIKit

class TranslateViewController: UIViewController, UITextViewDelegate {
    //    上のtextView
    @IBOutlet private var translateTextView1: UITextView!
    //    下のtextView
    @IBOutlet private var translateTextView2: UITextView!

    @IBOutlet private var label1: UILabel!

    //    日本語、英語切り替え
    @IBOutlet private var languageLabel1: UILabel!
    @IBOutlet private var languageLabel2: UILabel!

    @IBOutlet private var changeLanguageButton: UIButton!
    @IBOutlet private var saveButton: UIButton!
    @IBOutlet private var translateButton: UIButton!
    @IBOutlet private var selectFolderButton: UIButton!

    @IBOutlet private var view1: UIView!
    @IBOutlet private var view2: UIView!

    @IBOutlet private var copyButton1: UIButton!
    @IBOutlet private var copyButton2: UIButton!
    @IBOutlet private var volumeButton1: UIButton!
    @IBOutlet private var volumeButton2: UIButton!
    @IBOutlet private var deleteTextButton1: UIButton!
    @IBOutlet private var deleteTextButton2: UIButton!

    //    フォルダー名を格納
    var folderNameString: String?

    //    TabBarControllerインスタンス格納用の変数
    var tabBarController1: TabBarController!

    private var realm = try! Realm()
    private var translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)

    // 音声再生時の判別用の変数
    private var shouldSpeakWhenTappedVolumeButton1: Bool!
    private var shouldSpeakWhenTappedVolumeButton2: Bool!

    private var talker = AVSpeechSynthesizer()

    private let translateModel = TranslateModel()

    private let decoder: JSONDecoder = .init()

    private let disposeBag = DisposeBag() // ゴミ箱を設置したイメージ

    override func viewDidLoad() {
        super.viewDidLoad()

        self.translateTextView1.font = UIFont.boldSystemFont(ofSize: 15)
        self.translateTextView2.font = UIFont.boldSystemFont(ofSize: 15)

        self.translateTextView1.delegate = self

        // RxSwiftで翻訳ボタン押下イベントを監視
        self.observeTranslateButtonTapEvent()

        //        translateTextView2（下のtextView）タップして、viewをキーボードの高さ分あげるためのNotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        //        textViewとviewのデザイン設定
        self.setTranslateTextViewAndView()

        //        右下の保存先選択ボタンのデザイン設定
        self.setButtonDesign1(button: [self.selectFolderButton], pointSize: 18, weight: .medium, scale: .medium, systemName: ["square.and.arrow.down"], borderWidth: 1, borderColor: UIColor.systemBlue.cgColor, cornerRadius: 10)

        //        ボタンを格納して、それぞれボタンにデザイン設定
        let buttonArr1: [UIButton]! = [copyButton1, copyButton2, volumeButton1, volumeButton2, deleteTextButton1, deleteTextButton2]
        let systemNameArr = ["doc.on.doc", "doc.on.doc", "volume.3", "volume.3", "delete.left", "delete.left"]
        self.setButtonDesign1(button: buttonArr1, pointSize: 20, weight: .regular, scale: .small, systemName: systemNameArr, borderWidth: nil, borderColor: nil, cornerRadius: nil)

        //        ボタンを格納して、それぞれのボタンにデザイン設定
        let buttonArr2: [UIButton]! = [self.changeLanguageButton, self.saveButton, self.translateButton]
        self.setButtonDesign2(button: buttonArr2, borderColor: UIColor.systemBlue.cgColor, borderWidth: 1, cornerRadius: 10)

        //        左したに表示される保存ボタンの設定
        self.saveButton.isEnabled = false
        self.saveButton.isHidden = true
        self.saveButton.titleLabel?.numberOfLines = 1

        // キーボードに完了のツールバーを作成
        self.setDoneTooBar()

        //        TabBarControllerクラスに定義したメソッドにアクセスして、titleに"翻訳"と表示する
        self.tabBarController1.setStringToNavigationItemTitle0()
        self.tabBarController1.navigationController?.setNavigationBarHidden(false, animated: false)

        // self.label1はtextViewの上に表示させる（placeHolderみたいな感じ）
        self.label1.text = "ドラマや映画のフレーズや単語、自英作文などを入力して作成したフォルダーに保存しよう！"
        self.languageLabel1.text = "Japanese"
        self.languageLabel2.text = "English"
    }

    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if !self.translateTextView2.isFirstResponder {
            return
        }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            } else {
                let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                self.view.frame.origin.y -= suggestionHeight
            }
        }
    }

    //　　textViewとViewのデザイン設定
    private func setTranslateTextViewAndView() {
        let color = UIColor.systemGray4.cgColor
        self.translateTextView1.layer.borderColor = color
        self.translateTextView1.layer.borderWidth = 2
        self.translateTextView1.clipsToBounds = true

        self.translateTextView2.layer.borderWidth = 2
        self.translateTextView2.layer.borderColor = color
        self.translateTextView2.clipsToBounds = true

        self.view1.layer.borderWidth = 2
        self.view1.layer.borderColor = color

        self.view2.layer.borderWidth = 2
        self.view2.layer.borderColor = color
    }

    //    UIButtonのデザイン設定
    private func setButtonDesign1(button: [UIButton], pointSize: CGFloat, weight: UIImage.SymbolWeight, scale: UIImage.SymbolScale, systemName: [String], borderWidth: CGFloat?, borderColor: CGColor?, cornerRadius: CGFloat?) {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight, scale: scale)

        for i in 0 ... button.count - 1 {
            let systemIcon = UIImage(systemName: systemName[i], withConfiguration: config)
            button[i].setImage(systemIcon, for: .normal)
            if borderWidth != nil {
                button[i].layer.borderWidth = borderWidth!
                button[i].layer.borderColor = borderColor!
                button[i].layer.cornerRadius = cornerRadius!
            }
        }
    }

    //    UIbuttonのデザイン設定
    private func setButtonDesign2(button: [UIButton], borderColor: CGColor, borderWidth: CGFloat, cornerRadius: CGFloat) {
        button.forEach {
            $0.layer.borderColor = borderColor
            $0.layer.borderWidth = borderWidth
            $0.layer.cornerRadius = cornerRadius
        }
    }

    //    キーボードに完了バー
    private func setDoneTooBar() {
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        // 左側のBarButtonItemはflexibleSpace。これがないと右に寄らない。flexibleSpaceはBlank space to add between other items
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.doneButtonTaped))
        //        The items displayed on the toolbar.
        doneToolbar.items = [spacer, doneButton]
        let someArr = [translateTextView1, translateTextView2]
        for someNumber in someArr {
            //            // textViewのキーボードにツールバーを設定
            someNumber!.inputAccessoryView = doneToolbar
        }
    }

    @objc func doneButtonTaped(sender _: UIButton) {
        self.translateTextView1.endEditing(true)
        self.translateTextView2.endEditing(true)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        //        tabBarController1(TabBarControllerクラスのインスタンス)がある場合の処理
        self.setCreateFolderBarButtonItem()

        //        selectFolderForTranslateViewController（保存先指定画面）で作成したフォルダー名を保存先に指定し選択ボタンを押下して、translateViewController画面へ戻ってきた時の処理
        self.displaySaveButtonWithFolderName()
    }

    //    tabBarController1(TabBarControllerクラスのインスタンス)がある場合の処理
    private func setCreateFolderBarButtonItem() {
        if let tabBarController1 = tabBarController1 {
            tabBarController1.setStringToNavigationItemTitle0()
            tabBarController1.navigationController?.setNavigationBarHidden(false, animated: false)
            let createFolderBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(self.tappedCreateFolderBarButtonItem(_:)))
            self.tabBarController1?.navigationItem.rightBarButtonItems = [createFolderBarButtonItem]
        }
    }

    @objc func tappedCreateFolderBarButtonItem(_: UIBarButtonItem) {
        self.tabBarController1.createFolder()
    }

    private func displaySaveButtonWithFolderName() {
        //        self.folderNameStringには、保存先指定画面で指定したフォルダー名が格納される
        guard let folderNameString = self.folderNameString else { return }
        let translationFolderArr = self.realm.objects(TranslationFolder.self)
        var folderNameArr = [String]()

        if translationFolderArr.count == 0 {
            self.saveButton.isEnabled = false
            self.saveButton.isHidden = true
        } else {
            translationFolderArr.forEach { translationFolder in
                folderNameArr.append(translationFolder.folderName)
            }
        }

        if folderNameArr.contains(folderNameString) {
            self.saveButton.configuration?.title = "保存先▷\(folderNameString)"
            self.saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
            self.saveButton.isHidden = false
            self.saveButton.isEnabled = true
        } else {
            self.saveButton.isEnabled = false
            self.saveButton.isHidden = true
        }
    }

    // RxSwiftで翻訳ボタン押下イベントを監視
    private func observeTranslateButtonTapEvent() {
        self.translateButton.rx.tap.subscribe { _ in
            //        何も入力がなかった場合returnする
            if self.translateTextView1.text == "" {
                SVProgressHUD.showError(withStatus: "テキストを入力して、翻訳して下さい")
                SVProgressHUD.dismiss(withDelay: 1.5)
                return
            }

            self.translateButton.isEnabled = false

            if self.languageLabel1.text == "Japanese" {
                //        Japanese → English の場合
                self.bindModelToTranslateJp() // MVCに基づいてRxSwiftを使用してみた
            } else {
                //        English → Japanese
                self.bindModelToTranslateEng()
            }
        }
        .disposed(by: self.disposeBag)
    }

    @IBAction func changeLanguageButton(_: Any) {
        if self.languageLabel1.text == "Japanese" {
            self.languageLabel1.text = "English"
            self.languageLabel2.text = "Japanese"
        } else {
            self.languageLabel1.text = "Japanese"
            self.languageLabel2.text = "English"
        }
    }

    // 入力があるたびに呼ばれる
    func textViewDidChange(_ textView: UITextView) {
        guard textView == self.translateTextView1 else { return }

        if self.translateTextView1.text != "" {
            self.label1.text = ""
        } else {
            self.label1.text = "ドラマや映画のフレーズや単語、自英作文などを入力して作成したフォルダーに保存しよう！"
        }
    }

    // RXSwiftなし Result<Success, Failure: Error> + do try catchでやってみる
    private func bindModelToTranslateEng() {
        self.translateModel.translateEngText(text: self.translateTextView1.text) { result in
            if case let .success(translationResult) = result {
                let text = translationResult.translations[0].text.trimmingCharacters(in: .whitespaces)
                self.translateTextView2.text = text
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                SVProgressHUD.showSuccess(withStatus: "翻訳完了")
                SVProgressHUD.dismiss(withDelay: 1.5)
            }

            if case let .failure(error) = result {
                switch error {
                case let .decodeError(decodeError):
                    print("デコードエラー\(decodeError.localizedDescription)")
                case let .apiRequestError(apiRequestError, errorMessage):
                    print(errorMessage + "\(apiRequestError.localizedDescription)")
                }
                SVProgressHUD.showError(withStatus: "翻訳できませんでした")
            }

            self.translateButton.isEnabled = true
        }
    }

    // deeplResultObservableストリームを購読（監視) / 翻訳結果をUIに反映
    private func bindModelToTranslateJp() {
        // TranslateModelにあるAPIリクエストを含むメソッドを呼ぶ(translateText(text: String))
        let deeplResultObservable: Observable<DeepLResult> = self.translateModel.translateJpText(text: self.translateTextView1.text)
        deeplResultObservable.observe(on: MainScheduler.instance) // UI更新はメインスレッドで行う
            .subscribe(onNext: { [weak self] result in
                // .subscribeでtranslationObservableストリームの(onNextやonErrorによる)変化(イベント)を購読（監視）
                // completedかerrorが流れてくると、購読は解除される → onDispoed:のクロージャを呼び出す
                let text = result.translations[0].text.trimmingCharacters(in: .whitespaces)
                self?.translateTextView2.text = text
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                SVProgressHUD.showSuccess(withStatus: "翻訳完了")
                SVProgressHUD.dismiss(withDelay: 1.5)
            }, onError: { error in
                debugPrint("APIリクエストエラー: error:\(error) error.localizedDescription:\(error.localizedDescription)")
                SVProgressHUD.showError(withStatus: "翻訳できませんでした")
            }, onDisposed: { [weak self] in
                // シーケンスが正常に完了した時/エラーが流れてきた時などに実行される処理
                self?.translateButton.isEnabled = true
                print("onDispoed:のクロージャが呼び出された")
            })
            .disposed(by: self.disposeBag) // DisposeBagクラスで購読を一括で廃棄
        // .subscribeの返り値はDisposableオブジェクトなので、ここから.disposed呼ぶ 引数にself.disposeBagでゴミ箱を紐付けしただけ
        // メモリに確保されたクラスのインスタンスの解放(デイニシャライザ)時に、DisposeBagを自動的に実行
        self.translateButton.isEnabled = true
    }

//    （保存ボタン）保存先▷（フォルダー名）ボタンタップ時
    @IBAction func SaveButton(_: Any) {
        // どっちも、または、どちらかのtextViewが空の場合、return
        if self.translateTextView1.text.isEmpty || self.translateTextView2.text.isEmpty {
            SVProgressHUD.showError(withStatus: "保存に失敗しました\nテキストを入力してください")
            SVProgressHUD.dismiss(withDelay: 1.5)
            return
        }
        // どちらのtextViewにも入力があった場合はRealmに保存処理
        self.saveDataInTranslationFolderAndHistoryClass()
    }

    // TranslationFolderクラスとHistoryクラスへデータを保存
    private func saveDataInTranslationFolderAndHistoryClass() {
        if let folderNameString = folderNameString, let translateTextView1Text = self.translateTextView1.text, let translateTextView2Text = self.translateTextView2.text {
            // すでに作成して、realmに保存されたフォルダー名から、folderNameStringと同名のフォルダー名を検索して、
            let predicate = NSPredicate(format: "folderName == %@", folderNameString)
            // そのデータを取り出す
            // (同名のフォルダー名は存在しないようにしているため、self.translationFolderArrのデータの数は一つだけになる）
            self.translationFolderArr = self.realm.objects(TranslationFolder.self).filter(predicate)

            let translation = Translation()
            // 入力されたテキスト
            translation.inputData = translateTextView1Text
            // 翻訳結果テキスト
            translation.resultData = translateTextView2Text
            // 入力されたテキストと翻訳結果テキスト
            translation.inputAndResultData = translation.inputData + translation.resultData
            let translationArr = self.realm.objects(Translation.self)
            // idが被らないようにする
            if translationArr.count != 0 {
                translation.id = translationArr.max(ofProperty: "id")! + 1
            }

            // 書き込み（データは一つだけのため、firstで取り出す）
            try! self.realm.write {
                translationFolderArr.first!.results.append(translation)
            }
            //                    HistoryViewContoller(翻訳履歴画面）用にHistoryクラスへ保存
            let history = Histroy()
            let historyArr = self.realm.objects(Histroy.self)
            if historyArr.count != 0 {
                history.id = historyArr.max(ofProperty: "id")! + 1
            }

            // 書き込み
            try! self.realm.write {
                history.inputData = translateTextView1Text
                history.resultData = translateTextView2Text
                history.date = Date()
                history.inputAndResultData = history.inputData + history.resultData
                self.realm.add(history)
            }

            SVProgressHUD.showSuccess(withStatus: "'\(folderNameString)' へ保存しました")
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            self.saveButton.isEnabled = false
            SVProgressHUD.dismiss(withDelay: 1.5) {
                self.saveButton.isEnabled = true
            }
        }
    }

    @IBAction func deleteButton1(_: Any) {
        self.translateTextView1.text = ""
        self.label1.text = "ドラマや映画のフレーズや単語、自英作文などを入力して作成したフォルダーに保存しよう！"
    }

    @IBAction func deleteButton2(_: Any) {
        self.translateTextView2.text = ""
    }

    // 右下のフォルダー選択ボタン押下時
    @IBAction func selectFolderButton(_: Any) {
        let navigationController = storyboard?.instantiateViewController(withIdentifier: "FolderList") as! UINavigationController
        let selectFolderForTranslateViewContoller = navigationController.viewControllers[0] as! SelectFolderForTranslateViewContoller
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        selectFolderForTranslateViewContoller.translateViewController = self
        present(navigationController, animated: true, completion: nil)
    }

    internal func setFolderNameStringOnButton2() {
        self.tabBarController1.setStringToNavigationItemTitle0()
        self.tabBarController1.navigationController?.setNavigationBarHidden(false, animated: false)

        guard let folderNameString = self.folderNameString else {
            return
        }
        let translationFolderArr = self.realm.objects(TranslationFolder.self)
        var folderNameArr = [String]()
        if translationFolderArr.count == 0 {
            self.saveButton.isEnabled = false
            self.saveButton.isHidden = true
            return
        } else {
            for number in 0 ... translationFolderArr.count - 1 {
                folderNameArr.append(translationFolderArr[number].folderName)
            }
            translationFolderArr.forEach { translationFolder in
                folderNameArr.append(translationFolder.folderName)
            }
        }

        if folderNameArr.contains(folderNameString) {
            self.saveButton.configuration?.title = "保存先▷\(folderNameString)"
            self.saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
            self.saveButton.isHidden = false
            self.saveButton.isEnabled = true

        } else {
            self.saveButton.isEnabled = false
            self.saveButton.isHidden = true
        }
    }

    @IBAction func copyButton1(_: Any) {
        self.copyTextView(textView: self.translateTextView1, button: self.copyButton1)
    }

    @IBAction func copyButton2(_: Any) {
        self.copyTextView(textView: self.translateTextView2, button: self.copyButton2)
    }

    func copyTextView(textView: UITextView, button _: UIButton) {
        UIPasteboard.general.string = textView.text
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }

    //　translateTextView1の音声再生
    @IBAction func volumeButton1(_ sender: UIButton) {
        // contextMenuを表示
//        self.speak(textView: self.translateTextView1)
//        self.shouldSpeakWhenTappedVolumeButton1 = true
//        self.shouldSpeakWhenTappedVolumeButton2 = false
        self.configureMenuButtonForVoluemButton(volumeButton: sender)
    }

    //　translateTextView2の音声再生
    @IBAction func volumeButton2(_ sender: UIButton) {
        // contextMenuを表示
//        self.speak(textView: self.translateTextView2)
//        self.shouldSpeakWhenTappedVolumeButton2 = true
//        self.shouldSpeakWhenTappedVolumeButton1 = false
        self.configureMenuButtonForVoluemButton(volumeButton: sender)
    }

    // contextMenuを表示
    /*
     private func speak(textView: UITextView) {
         let english = ContextMenuItemWithImage(title: "英語音声", image: UIImage())
         let japanese = ContextMenuItemWithImage(title: "日本語音声", image: UIImage())
         let stop = ContextMenuItemWithImage(title: "停止", image: UIImage())
         CM.items = [english, japanese, stop]
         CM.showMenu(viewTargeted: textView, delegate: self, animated: true)
     }
      */

    private func configureMenuButtonForVoluemButton(volumeButton: UIButton) {
        var actions: [UIMenuElement] = []
        if #available(iOS 16.0, *) {
            self.volumeButton2.preferredMenuElementOrder = .fixed
        } else {
            // Fallback on earlier versions
            print("iOSが16.0ではないため、preferredMenuElementOrder = .fixed が有効になりません。")
        }
        actions.append(UIAction(title: "英語音声", handler: { _ in
            if volumeButton == self.volumeButton1 {
                self.implementSpeaking(translateTextView: self.translateTextView1, language: "en-US")
            } else if volumeButton == self.volumeButton2 {
                self.implementSpeaking(translateTextView: self.translateTextView2, language: "en-US")
            }
        }))
        actions.append(UIAction(title: "日本語音声", handler: { _ in
            if volumeButton == self.volumeButton1 {
                self.implementSpeaking(translateTextView: self.translateTextView1, language: "ja-JP")
            } else if volumeButton == self.volumeButton2 {
                self.implementSpeaking(translateTextView: self.translateTextView2, language: "ja-JP")
            }
        }))
        actions.append(UIAction(title: "音声停止", handler: { _ in
            self.talker.stopSpeaking(at: AVSpeechBoundary.immediate)
        }))

        volumeButton.menu = UIMenu(title: "", options: .displayInline, children: actions)
        volumeButton.showsMenuAsPrimaryAction = true
    }
}

extension TranslateViewController: ContextMenuDelegate {
    func contextMenuDidSelect(_: ContextMenu, cell _: ContextMenuCell, targetedView _: UIView, didSelect _: ContextMenuItem, forRowAt index: Int) -> Bool {
        //            音声再生停止
        self.talker.stopSpeaking(at: AVSpeechBoundary.immediate)

        switch index {
        case 0:
            if self.shouldSpeakWhenTappedVolumeButton1 {
                self.implementSpeaking(translateTextView: self.translateTextView1, language: "en-US")
            }

            if self.shouldSpeakWhenTappedVolumeButton2 {
                self.implementSpeaking(translateTextView: self.translateTextView2, language: "en-US")
            }
        //
        case 1:
            if self.shouldSpeakWhenTappedVolumeButton1 {
                self.implementSpeaking(translateTextView: self.translateTextView1, language: "ja-JP")
            }

            if self.shouldSpeakWhenTappedVolumeButton2 {
                self.implementSpeaking(translateTextView: self.translateTextView2, language: "ja-JP")
            }
        case 2:
            //            音声再生停止
            self.talker.stopSpeaking(at: AVSpeechBoundary.immediate)
        default:
            print("nilです")
        }
        return true
    }

//    音声再生を実行するメソッド
    private func implementSpeaking(translateTextView: UITextView, language: String) {
        self.talker.stopSpeaking(at: AVSpeechBoundary.immediate)
        let spokenText = translateTextView.text!
        //                話す内容をセット
        let utterance = AVSpeechUtterance(string: spokenText)
        //            言語を英語に設定
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        //            実行
        self.talker.speak(utterance)
    }

    func contextMenuDidDeselect(_: ContextMenu, cell _: ContextMenuCell, targetedView _: UIView, didSelect _: ContextMenuItem, forRowAt _: Int) {}

    func contextMenuDidAppear(_: ContextMenu) {
        print("メニューが表示されました")
    }

    func contextMenuDidDisappear(_: ContextMenu) {
        print("メニューが閉じました")
    }
}
