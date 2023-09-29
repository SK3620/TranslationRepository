//
//  SecondMemoForStudyViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/02/14.
//

import RealmSwift
import SVProgressHUD
import UIKit

class SecondMemoForStudyViewController: UIViewController {
    @IBOutlet private var memoTextView: UITextView!

    internal var translationId: Int!
    internal var memo: String = ""
    internal var sentenceNum: Int!

    private var realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "No." + String(self.sentenceNum + 1)
        self.memoTextView.text = self.memo

        self.setDoneToolBar()
        self.settingNavBarColor()
        self.settingBarButtonItem()
    }

    private func setDoneToolBar() {
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.doneButtonTapped(_:)))
        doneToolbar.items = [spacer, doneButton]
        self.memoTextView.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonTapped(_: UIButton) {
        self.memoTextView.endEditing(true)
    }

    private func settingNavBarColor() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.systemGray6
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func settingBarButtonItem() {
        // 戻るボタン
        let backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: self, action: #selector(self.backToPreviousScreen))
        self.navigationItem.leftBarButtonItem = backBarButtonItem

        // メモ保存ボタン
        let saveBarButtonItem = UIBarButtonItem(title: "保存する", style: .done, target: self, action: #selector(self.saveMemoText(_:)))
        self.navigationItem.rightBarButtonItem = saveBarButtonItem
    }

    // 戻る
    @objc func backToPreviousScreen() {
        self.dismiss(animated: true)
    }

    // メモを保存する
    @objc func saveMemoText(_: UIButton) {
        let translationArr = self.realm.objects(Translation.self).filter("id == \(self.translationId!)").first!
        try! self.realm.write {
            translationArr.secondMemo = self.memoTextView.text
            self.realm.add(translationArr, update: .modified)
        }
        SVProgressHUD.showSuccess(withStatus: "保存しました")
        SVProgressHUD.dismiss(withDelay: 1.5) {
            self.dismiss(animated: true)
        }
    }
}
