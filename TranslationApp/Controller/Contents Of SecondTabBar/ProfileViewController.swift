//
//  ProfileViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/27.
//

import CLImageEditor
import Firebase
import FirebaseStorageUI
import Parchment
import SVProgressHUD
import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var pasingView: UIView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var workLabel: UILabel!
    @IBOutlet var changePhotoButton: UIButton!
    @IBOutlet var label1: UILabel!

    @IBOutlet var likeNumberLabel: UILabel!
    @IBOutlet var postNumberLabel: UILabel!

    var image: UIImage!
    var tabBarController1: TabBarController?
    var secondTabBarController: SecondTabBarController!
    var rightBarButtonItem: UIBarButtonItem!
    var rightEdgeBarButtonItem: UIBarButtonItem!

    var profileData: [String: Any] = [:]

    var pagingViewController: PagingViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        if Auth.auth().currentUser == nil {
//            ログインしていない時の処理
            let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "Login") as! LoginViewController
//            loginViewController.logoutButton.isEnabled = false
            self.present(loginViewController, animated: true, completion: nil)
        }

        let introductionViewController = storyboard?.instantiateViewController(identifier: "introduction") as! IntroductionViewController
        introductionViewController.secondTabBarController = self.secondTabBarController

        let navigationController = storyboard?.instantiateViewController(withIdentifier: "NC") as! UINavigationController
        let postsHistoryViewController = navigationController.viewControllers[0] as! PostsHistoryViewController
        postsHistoryViewController.delegate = self

        let postedCommentsHistoryViewController = storyboard?.instantiateViewController(withIdentifier: "postedCommentsHistory") as! PostedCommentsHistoryViewController

        let navigationController2 = storyboard?.instantiateViewController(withIdentifier: "NC2") as! UINavigationController

        introductionViewController.title = "自己紹介"
        navigationController.title = "投稿履歴"
        postedCommentsHistoryViewController.title = "コメント履歴"
        navigationController2.title = "ブックマーク"

//        pagingViewControllerのインスタンス生成
        let pagingViewController = PagingViewController(viewControllers: [introductionViewController, navigationController, postedCommentsHistoryViewController, navigationController2])

//        Adds the specified view controller as a child of the current view controller.
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
//        Called after the view controller is added or removed from a container view controller.
        pagingViewController.didMove(toParent: self)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pagingViewController.view.leadingAnchor.constraint(equalTo: self.pasingView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pagingViewController.view.trailingAnchor.constraint(equalTo: self.pasingView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pagingViewController.view.bottomAnchor.constraint(equalTo: self.pasingView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pagingViewController.view.topAnchor.constraint(equalTo: self.pasingView.safeAreaLayoutGuide.topAnchor).isActive = true
        pagingViewController.selectedTextColor = .black
        pagingViewController.textColor = .systemGray4
        pagingViewController.indicatorColor = .systemBlue
        pagingViewController.menuItemSize = .sizeToFit(minWidth: 100, height: 50)
        pagingViewController.menuItemLabelSpacing = 0
        pagingViewController.select(index: 1)
        self.pagingViewController = pagingViewController
        introductionViewController.pagingViewController = pagingViewController

        self.navigationController?.navigationBar.backgroundColor = .systemGray4

        //        丸いimageView
        self.imageView.layer.cornerRadius = self.imageView.frame.height / 2
        //        画像にデフォルト設定
        self.imageView.image = UIImage(systemName: "person")
        self.imageView.layer.borderColor = UIColor.systemGray4.cgColor
        self.imageView.layer.borderWidth = 2.5
    }

    @objc func tappedRightBarButtonItem(_: UIBarButtonItem) {
        self.performSegue(withIdentifier: "ToEditProfile", sender: nil)
    }

    @objc func tappedRightEdgeBarButtonItem(_: UIBarButtonItem) {
        let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "Login")
        self.present(loginViewController, animated: true, completion: nil)
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        self.setRightBarButtonItem()

        //        currentUserがnilなら
        if Auth.auth().currentUser == nil {
            self.changePhotoButton.isEnabled = false
            self.likeNumberLabel.text = ""
            self.postNumberLabel.text = ""

            self.userNameLabel.text = "ー"
            self.genderLabel.text = "ー"
            self.ageLabel.text = "ー"
            self.workLabel.text = "ー"

            self.label1.text = "アカウントを作成/ログインしてください"
            let image = UIImage(systemName: "person")
            self.imageView.image = image

            self.rightBarButtonItem.isEnabled = false
            self.changePhotoButton.isEnabled = false
        }

        SVProgressHUD.show(withStatus: "データ取得中...")
        if Auth.auth().currentUser != nil {
            self.changePhotoButton.isEnabled = true
            self.label1.text = ""

            self.setImageFromStorage()
            if let user = Auth.auth().currentUser {
                print("実行されたを")
                Firestore.firestore().collection(FireBaseRelatedPath.profileData).document("\(user.uid)'sProfileDocument").getDocument { snap, error in
                    if let error = error {
                        print("取得失敗\(error)")
                    }
                    //                Retrieves all fields in the document as an `NSDictionary`. Returns `nil` if the document doesn't exist.
                    //                Declaration
                    //                func data() -> [String : Any]?
                    if let profileData = snap?.data() {
                        self.profileData = profileData
                    }
                    self.setProfileDataOnLabels(profileData: self.profileData)
                    SVProgressHUD.dismiss()
                }
                print("実行されたを２")
            }
        }
    }

    func setRightBarButtonItem() {
        self.secondTabBarController.rightBarButtonItems = []
        self.secondTabBarController.navigationController?.setNavigationBarHidden(false, animated: false)
        let rightEdgeBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "text.justify"), style: .plain, target: self, action: #selector(self.tappedRightEdgeBarButtonItem(_:)))
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil.tip.crop.circle.badge.plus"), style: .plain, target: self, action: #selector(self.tappedRightBarButtonItem(_:)))
        self.rightBarButtonItem = rightBarButtonItem
        self.rightEdgeBarButtonItem = rightEdgeBarButtonItem
        self.secondTabBarController.rightBarButtonItems.append(rightEdgeBarButtonItem)
        self.secondTabBarController.rightBarButtonItems.append(rightBarButtonItem)
        self.secondTabBarController.navigationItem.rightBarButtonItems = self.secondTabBarController.rightBarButtonItems
        self.secondTabBarController.title = "プロフィール"
    }

    func setProfileDataOnLabels(profileData _: [String: Any]) {
        self.userNameLabel.text = Auth.auth().currentUser?.displayName!
        if let genderText = self.profileData["gender"] as? String {
            self.genderLabel.text = genderText
        } else {
            self.genderLabel.text = "ー"
        }

        if let ageText = self.profileData["age"] as? String {
            self.ageLabel.text = ageText
        } else {
            self.ageLabel.text = "ー"
        }

        if let workText = self.profileData["work"] as? String {
            self.workLabel.text = workText
        } else {
            self.workLabel.text = "ー"
        }
    }

    func setImageFromStorage() {
        if Auth.auth().currentUser != nil {
            //            storageから画像を取り出して、imageViewに設置
            let user = Auth.auth().currentUser!
            let imageRef: StorageReference = Storage.storage().reference(forURL: "gs://translationapp-72dd8.appspot.com").child(FireBaseRelatedPath.imagePath).child("\(user.uid)" + ".jpg")

            // キャッシュを更新して、画像をセット
            self.imageView.sd_setImage(with: imageRef)
            print("画像取り出せた？\(imageRef)")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "ToEditProfile" {
            let editProfileViewController = segue.destination as! EditProfileViewController
            editProfileViewController.profileViewController = self
            editProfileViewController.secondTabBarController = self.secondTabBarController
        }
    }

    //    写真ライブラリを開くボタン
    @IBAction func openLibraryButton(_: Any) {
        //        ライブラリを開く
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }

    //    写真選択時に呼ばれる
    // 写真を撮影/選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // UIImagePickerController画面を閉じる
        picker.dismiss(animated: true, completion: nil)
        // 画像加工処理
        if info[.originalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[.originalImage] as! UIImage
            //           画像を加工する
            let editor = CLImageEditor(image: image)!
            editor.delegate = self
            self.present(editor, animated: true, completion: nil)
        }
    }

    // CLImageEditorで加工が終わったときに呼ばれるメソッド
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        editor.dismiss(animated: true, completion: { () in
            self.image = image
            self.imageView.image = self.image
            self.saveImageToStorage()
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // UIImagePickerController画面を閉じる
        picker.dismiss(animated: true, completion: nil)
    }

    //    画像ファイルをstorageに保存する
    func saveImageToStorage() {
        //        プロフィール画像sekf.imageをJPEG形式に変換
        let imageData = self.image.jpegData(compressionQuality: 0.75)
        //        画像の保存場所定義
        let user = Auth.auth().currentUser!
        let imageRef: StorageReference = Storage.storage().reference(forURL: "gs://translationapp-72dd8.appspot.com").child(FireBaseRelatedPath.imagePath).child("\(user.uid)" + ".jpg")
//        let imageRef: StorageReference? = Storage.storage().reference(withPath: path)

        SVProgressHUD.show()
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        imageRef.putData(imageData!, metadata: metaData) { metadata, error in
            if error != nil {
                // 画像のアップロード失敗
                print(error!)
                SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                return
            }
            if metadata != nil {
                print("画像のアップロードに成功しました")
            }
            SVProgressHUD.dismiss()
        }
    }
}

extension ProfileViewController: setLikeAndPostNumberLabelDelegate {
//    いいね数と投稿数を表示させる
    func setLikeAndPostNumberLabel(likeNumber: Int, postNumber: Int) {
        self.likeNumberLabel.text = "いいね \(String(likeNumber))"
        self.postNumberLabel.text = "投稿 \(String(postNumber))"
    }
}