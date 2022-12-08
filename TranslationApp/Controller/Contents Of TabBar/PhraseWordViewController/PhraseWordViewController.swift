//
//  PhraseViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/18.
//

import Parchment
import RealmSwift
import SVProgressHUD
import UIKit

class PhraseWordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var view1: UIView!
    @IBOutlet var label1: UILabel!

    let realm = try! Realm()
    var phraseWordArr: Results<PhraseWord>!
//    入力した文章とその翻訳結果を格納する配列
    var inputDataList = [String]()
    var resultDataList = [String]()

    var tabBarController1: TabBarController?
    var pagingPhraseWordViewController: PagingPhraseWordViewController?
    var studyViewController: StudyViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.separatorColor = UIColor.systemBlue
        self.tableView.delegate = self
        self.tableView.dataSource = self

        let nib = UINib(nibName: "CustomCellForPhraseWord", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        if self.studyViewController != nil {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            print("studyViewControllerが実行された")
        }

        let editBarButtonItem = UIBarButtonItem(title: "編集", style: .plain, target: self, action: #selector(self.tappedEditBarButtonItem(_:)))
        //       rightBarButtonItemsにeditBarButtonItemとcreateFolderBarButtonItemの二つが格納されていたら、前者をremoveする
        if self.tabBarController1!.navigationItem.rightBarButtonItems?.count == 2 {
            self.tabBarController1?.navigationItem.rightBarButtonItems?.remove(at: 0)
        }
        self.tabBarController1?.navigationItem.rightBarButtonItems?.insert(editBarButtonItem, at: 0)

        //        studyViewController画面からmodal遷移した時の処理
        if self.studyViewController != nil {
            self.pagingPhraseWordViewController!.navigationItem.rightBarButtonItems = []
            self.pagingPhraseWordViewController!.navigationItem.rightBarButtonItems = [editBarButtonItem]
        }

        self.tableView.isEditing = false
        self.setValueForPhraseWord()
        self.tableView.reloadData()
    }

    @objc func tappedEditBarButtonItem(_: UIBarButtonItem) {
        if self.tableView.isEditing {
            self.tableView.isEditing = false
            print("false")
        } else {
            self.tableView.isEditing = true
            print("true")
        }
    }

    func setValueForPhraseWord() {
        //        phraseWordArrに値があれば、appendする。
        self.inputDataList = []
        self.resultDataList = []
        self.phraseWordArr = try! Realm().objects(PhraseWord.self).sorted(byKeyPath: "date", ascending: true).filter("isChecked == 0")
        if self.phraseWordArr.count != 0 {
            //            self.editButton.isEnabled = true
            for number in 0 ... self.phraseWordArr.count - 1 {
                self.inputDataList.append(self.phraseWordArr[number].inputData)
                self.resultDataList.append(self.phraseWordArr[number].resultData)
                self.label1.text = ""
            }
        } else {
            self.label1.text = "お気に入りの単語・フレーズを追加しよう！"
        }
    }

    @objc func tappedBackBarButtonItem(_: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidDisappear(_: Bool) {
        super.viewDidDisappear(true)
        if self.studyViewController == nil {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if self.inputDataList.isEmpty {
            self.label1.text = "お気に入りの単語・フレーズを追加しよう！"
        }
        return self.inputDataList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForPhraseWord
        cell.setData1(self.inputDataList[indexPath.row], indexPath.row)

        //           タップされたセル内の星マークボタンのtagを設定
        cell.checkMarkButton.tag = indexPath.row
        cell.checkMarkButton.addTarget(self, action: #selector(self.tapCellButton(_:)), for: .touchUpInside)

        //         星マークが3種類のため、Boolではなく、Int型でswitch判定
        let isChecked = self.phraseWordArr[indexPath.row].isChecked
        switch isChecked {
        case 0:
            let image0 = UIImage(systemName: "star")
            cell.checkMarkButton.setImage(image0, for: .normal)

        case 1:
            let image1 = UIImage(systemName: "star.leadinghalf.filled")
            cell.checkMarkButton.setImage(image1, for: .normal)

        case 2:
            let image2 = UIImage(systemName: "star.fill")
            cell.checkMarkButton.setImage(image2, for: .normal)

        default:
            print("nil")
        }

        //　　　　文章タップで表示、非表示切り替えボタン
        //           label1の上に設置したボタン
        cell.displayButton1.tag = indexPath.row
        cell.displayButton1.addTarget(self, action: #selector(self.tapDisplayButton(_:)), for: .touchUpInside)
        //       　　　label2の上に設置したボタン
        cell.displayButton2.tag = indexPath.row
        cell.displayButton2.addTarget(self, action: #selector(self.tapDisplayButton(_:)), for: .touchUpInside)

        let isDisplayed = self.phraseWordArr[indexPath.row].isDisplayed
        switch isDisplayed {
        case false:
            if indexPath.row == 0 {
                cell.label2.text = ""
                let image = UIImage(systemName: "hand.tap")
                cell.displayButton2.setImage(image, for: .normal)
                cell.displayButton2.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            } else if indexPath.row != 0 {
                cell.label2.text = ""
                cell.displayButton2.setImage(UIImage(), for: .normal)
                cell.displayButton2.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            }
        case true:
            cell.displayButton2.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            cell.displayButton2.setImage(UIImage(), for: .normal)
            cell.setData2(self.resultDataList[indexPath.row])
        }
        return cell
    }

    //　　　checkMarkButton(星マークボタン）タップ時
    @objc func tapCellButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "登録", message: "'星0.5'へ登録しますか？", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        let register = UIAlertAction(title: "登録", style: .default) { _ in

            let isChecked = self.phraseWordArr[sender.tag].isChecked
            switch isChecked {
            case 0:
                try! Realm().write {
                    self.phraseWordArr[sender.tag].isChecked = 1
                    self.realm.add(self.phraseWordArr, update: .modified)
                }
            case 1:
                try! Realm().write {
                    self.phraseWordArr[sender.tag].isChecked = 2
                    self.realm.add(self.phraseWordArr, update: .modified)
                }
            case 2:
                try! Realm().write {
                    self.phraseWordArr[sender.tag].isChecked = 0
                    self.realm.add(self.phraseWordArr, update: .modified)
                }

            default:
                print("その他の値です")
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.setValueForPhraseWord()
                self.tableView.reloadData()
                SVProgressHUD.showSuccess(withStatus: "登録完了")
                SVProgressHUD.dismiss(withDelay: 1.5)
            }
        }

        alert.addAction(cancel)
        alert.addAction(register)

        present(alert, animated: true, completion: nil)
    }

    //    文章タップで表示、非表示切り替えボタンタップ時
    @objc func tapDisplayButton(_ sender: UIButton) {
        let isDisplayed = self.phraseWordArr[sender.tag].isDisplayed
        switch isDisplayed {
        case false:
            try! Realm().write {
                phraseWordArr[sender.tag].isDisplayed = true
                realm.add(phraseWordArr, update: .modified)
            }
        case true:
            try! Realm().write {
                phraseWordArr[sender.tag].isDisplayed = false
                realm.add(phraseWordArr, update: .modified)
            }
        }
        self.setValueForPhraseWord()
        self.tableView.reloadData()
    }

    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    //    deleteボタンが押された時
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //            データベースから削除する
            try! self.realm.write {
                self.realm.delete(self.phraseWordArr[indexPath.row])
                self.inputDataList.remove(at: indexPath.row)
                self.resultDataList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            self.setValueForPhraseWord()
            tableView.reloadData()
        }
    }
}

//    編集ボタンタップ時
//    @IBAction func editButtonAction(_: Any) {
//        self.tableView.isEditing = false
//        //        コンテキストメニューの内容を作成
//        let delete = ContextMenuItemWithImage(title: "一部削除する", image: UIImage())
//        let deleteAll = ContextMenuItemWithImage(title: "全て削除する", image: UIImage())
//
//        //        表示するアイテムを決定
//        CM.items = [delete, deleteAll]
//        //        表示します
//        CM.showMenu(viewTargeted: self.view1, delegate: self, animated: true)
//    }
// }
//
// extension PhraseWordViewController: ContextMenuDelegate {
//    func contextMenuDidDeselect(_: ContextMenu, cell _: ContextMenuCell, targetedView _: UIView, didSelect _: ContextMenuItem, forRowAt _: Int) {}
//
//    //    コンテキストメニューが表示された時の挙動を設定
//
//    //    コンテキストメニューの選択肢が選択された時に実行される
//    //            - Parameters:
//    //                - contextMenu: そのコンテキストメニューだと思われる
//    //                - cell: **選択されたコンテキストメニューの**セル
//    //                - targetView: コンテキストメニューの発生源のビュー
//    //                - item: 選択されたコンテキストのアイテム(タイトルとか画像とかが入ってる)
//    //                - index: **選択されたコンテキストのアイテムの**座標
//    //            - Returns: よくわからない(多分成功したらtrue...?
//    //         */
//    func contextMenuDidSelect(_: ContextMenu,
//                              cell _: ContextMenuCell,
//                              targetedView _: UIView,
//                              didSelect _: ContextMenuItem,
//                              forRowAt index: Int) -> Bool
//    {
//        switch index {
//        case 0:
//            self.tableView.isEditing = true
////            self.editButton.setTitle("完了", for: .normal)
//        case 1:
//            self.setUIAlertController()
//        default:
//            print("他の値")
//        }
//        return true
//    }
//
//    //         コンテキストメニューが表示されたら呼ばれる
//    func contextMenuDidAppear(_: ContextMenu) {
//        print("コンテキストメニュー表示されました")
//    }
//
//    //         コンテキストメニューが消えたら呼ばれる
//    func contextMenuDidDisappear(_: ContextMenu) {
//        print("コンテキストメニューが消えました")
//    }
//
//    func setUIAlertController() {
//        let alert = UIAlertController(title: "削除", message: "本当に全て削除してもよろしいですか？", preferredStyle: .alert)
//        let delete = UIAlertAction(title: "削除", style: .default, handler: { _ in
//
//            do {
//                let realm = try Realm()
//                try realm.write {
//                    self.realm.delete(self.phraseWordArr)
//                    self.inputDataList = []
//                    self.resultDataList = []
//                }
//
//                self.tableView.reloadData()
////                self.editButton.setTitle("編集", for: .normal)
//            } catch {
//                print("エラー")
//            }
//            self.label1.text = "お気に入りの単語・フレーズを追加しよう！"
//        })
//
//        let cencel = UIAlertAction(title: "キャンセル", style: .default, handler: { _ in print("キャンセルボタンがタップされた。")
//        })
//
//        alert.addAction(delete)
//        alert.addAction(cencel)
//
//        present(alert, animated: true, completion: nil)
//    }
// }

/*
 // MARK: - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */