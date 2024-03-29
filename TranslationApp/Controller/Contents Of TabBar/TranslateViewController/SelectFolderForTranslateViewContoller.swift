//
//  FolderListViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/31.
//

import RealmSwift
import UIKit

class SelectFolderForTranslateViewContoller: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private var tableView: UITableView!

    @IBOutlet private var selectButton: UIButton!

    @IBOutlet private var folderNameLabel: UILabel!
    @IBOutlet private var label: UILabel!

    var translateViewController: TranslateViewController!

    private let realm = try! Realm()
    private let translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)

    var folderNameString: String = ""
    private var string: String = "保存先 : "

    override func viewDidLoad() {
        super.viewDidLoad()

        self.settingsForNavigationBarAppearence()

        self.folderNameLabel.text = self.string

        self.selectButton.layer.borderWidth = 1
        self.selectButton.layer.borderColor = UIColor.systemBlue.cgColor
        self.selectButton.layer.cornerRadius = 10

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .systemBlue
        self.tableView.layer.borderColor = UIColor.white.cgColor

        // translationFolderArrにデータがない場合
        if self.translationFolderArr.count == 0 {
            self.title = "フォルダーを作成して下さい"
            self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.orange]
            self.selectButton.isEnabled = false
        } else {
            // データがあった場合
            self.title = "保存先を選択して下さい"
            self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
            self.selectButton.isEnabled = false
        }
    }

    private func settingsForNavigationBarAppearence() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.systemGray6
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.translationFolderArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let folderName = self.translationFolderArr[indexPath.row].folderName

        let date = self.translationFolderArr[indexPath.row].date
        let dateString = self.getDate(date: date)

        cell.imageView?.image = UIImage(systemName: "folder")
        cell.textLabel?.text = folderName
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = "作成日:\(dateString)"

        return cell
    }

    private func getDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        let dateString: String = formatter.string(from: date)
        return dateString
    }

    //    セルが選択された時
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップされたindexPath情報からfolderNameを取り出す
        let folderName = self.translationFolderArr[indexPath.row].folderName
        self.folderNameLabel.text! = self.string + folderName
        self.selectButton.isEnabled = true
        self.folderNameString = folderName
    }

    @IBAction func backButton(_: Any) {
        self.dismiss(animated: true)
    }

    // 右下の選択ボタンタップ時
    @IBAction func selectButton(_: Any) {
        self.translateViewController.folderNameString = self.folderNameString
        // translateViewController画面の左下の保存ボタンをisEnabledにして、そのボタン上にfolderNameを表示させる
        self.translateViewController.setFolderNameStringOnButton2()
        dismiss(animated: true)
    }
}
