//
//  HogeViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/05.
//

import Firebase
import MessageUI
import SVProgressHUD
import UIKit

// the screen which displays the comments on the post which you tapped
class CommentsHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    var postData: PostData!
    var postArray: [PostData] = []
    var secondPostArray: [SecondPostData] = []

    private var listener: ListenerRegistration?
    private var listener2: ListenerRegistration?

    var profileViewController: ProfileViewController?

    var comment: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        self.settingsForNavigationBarAppearenece()

        self.settingsForTableView()
    }

    private func settingsForNavigationBarAppearenece() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func settingsForTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib(nibName: "CustomCellForTimeLine", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
        let nib2 = UINib(nibName: "CustomCellForCommentSetion", bundle: nil)
        self.tableView.register(nib2, forCellReuseIdentifier: "CustomCell2")
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: nil, action: nil)

        if let profileViewController = self.profileViewController {
            profileViewController.commentsHistoryViewController = self
        }

        if Auth.auth().currentUser == nil {
            self.secondPostArray = []
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
            return
        }

        if Auth.auth().currentUser != nil {
            GetDocument.getSingleDocument(postData: self.postData, listener: self.listener) { result in
                switch result {
                case let .failure(error):
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error.localizedDescription)")
                    SVProgressHUD.showError(withStatus: "データの取得に失敗しました")
                case let .success(postData):
                    self.postData = postData
                    self.postArray = []
                    self.postArray.append(postData)

                    let user = Auth.auth().currentUser!
                    if postData.blockedBy.contains(user.uid) {
                        self.postArray = []
                    }
                    SVProgressHUD.dismiss()
                    self.tableView.reloadData()
                }
            }

            let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("documentIdForPosts", isEqualTo: self.postData.documentId).order(by: "commentedDate", descending: true)
            GetDocument.getCommentsDocuments(query: commentsRef, listener: self.listener) { result in
                switch result {
                case let .failure(error):
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error.localizedDescription)")
                    SVProgressHUD.showError(withStatus: "データの取得に失敗しました")
                case let .success(secondPostArray):
                    self.secondPostArray = secondPostArray
                    SVProgressHUD.dismiss()
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener?.remove()
        self.listener2?.remove()
    }

    func reloadTableView() {
        self.tableView.reloadData()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if self.postArray.isEmpty {
            self.secondPostArray = []
        }
        if Auth.auth().currentUser != nil {
            return self.secondPostArray.count + self.postArray.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForTimeLine

        cell.commentButton.isEnabled = true
        cell.commentButton.isHidden = false
        cell.bookMarkButton.isEnabled = true
        cell.bookMarkButton.isHidden = false
        cell.cellEditButton.isEnabled = true
        cell.cellEditButton.isHidden = false

        if indexPath.row == 0 {
            cell.cellEditButton.isEnabled = false
            cell.cellEditButton.isHidden = true
        }

        cell.heartButton.addTarget(self, action: #selector(self.tappedHeartButton(_:forEvent:)), for: .touchUpInside)

        cell.bookMarkButton.addTarget(self, action: #selector(self.tappedBookMarkButton(_:forEvent:)), for: .touchUpInside)

        cell.copyButton.addTarget(self, action: #selector(self.tappedCopyButton(_:forEvent:)), for: .touchUpInside)

        cell.commentButton.addTarget(self, action: #selector(self.tappedCommentButton(_:forEvent:)), for: .touchUpInside)

        cell.cellEditButton.addTarget(self, action: #selector(self.tappedCellEditButton(_:forEvent:)), for: .touchUpInside)

        // display the content of the post in the top cell
        // in the other cells, display the content of the comments on the post
        if indexPath.row == 0 {
            cell.setPostData(self.postData)
            return cell
        }

        let cell2 = tableView.dequeueReusableCell(withIdentifier: "CustomCell2", for: indexPath) as! CustomCellForCommentSetion

        cell2.cellEditButton.isEnabled = true
        cell2.cellEditButton.isHidden = false
        cell2.bookMarkButton.isEnabled = false
        cell2.bookMarkButton.isHidden = true

        let seoncdPostData = self.secondPostArray[indexPath.row - 1]
        let user = Auth.auth().currentUser!
        if indexPath.row > 0, seoncdPostData.uid == user.uid {
            cell2.cellEditButton.isEnabled = false
            cell2.cellEditButton.isHidden = true
        }

        cell2.setSecondPostData(secondPostData: self.secondPostArray[indexPath.row - 1])

        cell2.heartButton.addTarget(self, action: #selector(self.tappedHeartButtonInComment(_:forEvent:)), for: .touchUpInside)

        cell2.copyButton.addTarget(self, action: #selector(self.tappedCopyButtonInComment(_:forEvent:)), for: .touchUpInside)

        cell2.cellEditButton.addTarget(self, action: #selector(self.tappedCellEditButton(_:forEvent:)), for: .touchUpInside)

        return cell2
    }

    @objc func tappedHeartButton(_: UIButton, forEvent _: UIEvent) {
        let postData = self.postData!

        if let myid = Auth.auth().currentUser?.uid {
            var updateValue: FieldValue
            if postData.isLiked {
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                updateValue = FieldValue.arrayUnion([myid])
            }
            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
            postRef.updateData(["likes": updateValue])
        }
    }

    @objc func tappedBookMarkButton(_: UIButton, forEvent _: UIEvent) {
        let postData = self.postData!

        if let myid = Auth.auth().currentUser?.uid {
            if postData.isBookMarked {
                let alert = UIAlertController(title: "ブックマークへの登録を解除しますか？", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "解除", style: .default, handler: { _ in
                    let updateValue = FieldValue.arrayRemove([myid])
                    let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
                    SVProgressHUD.showSuccess(withStatus: "登録解除")
                    SVProgressHUD.dismiss(withDelay: 1.0) {
                        postRef.updateData(["bookMarks": updateValue])
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                let updateValue = FieldValue.arrayUnion([myid])
                let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
                SVProgressHUD.showSuccess(withStatus: "ブックマークに登録しました")
                SVProgressHUD.dismiss(withDelay: 1.0) {
                    postRef.updateData(["bookMarks": updateValue])
                }
            }
        }
    }

    @objc func tappedCopyButton(_: UIButton, forEvent _: UIEvent) {
        let postData = self.postData
        let contentOfPost = postData!.contentOfPost
        UIPasteboard.general.string = contentOfPost
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }

    @objc func tappedHeartButtonInComment(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let secondPostData = self.secondPostArray[indexPath!.row - 1]

        if let myid = Auth.auth().currentUser?.uid {
            var updateValue: FieldValue
            if secondPostData.isLiked {
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                updateValue = FieldValue.arrayUnion([myid])
            }
            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).document(secondPostData.documentId!)
            postRef.updateData(["likes": updateValue])
        }
    }

    @objc func tappedCopyButtonInComment(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let secondPostData = self.secondPostArray[indexPath!.row - 1]
        let comment = secondPostData.comment
        UIPasteboard.general.string = comment
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }

    @objc func tappedCommentButton(_: UIButton, forEvent _: UIEvent) {
        let postData = self.postData
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "InputComment") as! UINavigationController
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        let inputCommentViewContoller = navigationController.viewControllers[0] as! InputCommentViewController
        inputCommentViewContoller.postData = postData
        inputCommentViewContoller.commentsHistoryViewController = self
        inputCommentViewContoller.textView_text = self.comment
        self.present(navigationController, animated: true, completion: nil)
    }

    @objc func tappedCellEditButton(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        let reportAction = UIAlertAction(title: "通報", style: .default) { _ in
            if indexPath?.row == 0 {
                self.tappedReportButton(postData: self.postData)
            } else {
                let secondPostData = self.secondPostArray[indexPath!.row - 1]
                self.tappedReportButtonInCommentSection(secondPostData: secondPostData)
            }
        }
        let blockAction = UIAlertAction(title: "ブロック", style: .default) { _ in
            if indexPath?.row == 0 {
                self.setUIAlert(postData: self.postData, secondPostData: nil)
            } else {
                let secondPostData = self.secondPostArray[indexPath!.row - 1]
                self.setUIAlert(postData: nil, secondPostData: secondPostData)
            }
        }
        alert.addAction(reportAction)
        let user = Auth.auth().currentUser!
        if indexPath?.row == 0, self.postData.uid != user.uid {
            alert.addAction(blockAction)
        }
        if indexPath?.row != 0, self.secondPostArray[indexPath!.row - 1].uid != user.uid {
            alert.addAction(blockAction)
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    private func setUIAlert(postData: PostData?, secondPostData: SecondPostData?) {
        var userName = ""
        var uid = ""
        if let postData = postData {
            userName = postData.userName!
            uid = postData.uid!
        }
        if let secondPostData = secondPostData {
            userName = secondPostData.userName!
            uid = secondPostData.uid!
        }

        let alert = UIAlertController(title: "'\(userName)'さんをブロックしますか？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "はい", style: .destructive, handler: { _ in
            SVProgressHUD.showSuccess(withStatus: "'\(userName)'さんをブロックしました")
            SVProgressHUD.dismiss(withDelay: 1.5) {
                let user = Auth.auth().currentUser!
                BlockUnblock.blockUserInCommentsCollection(uid: uid, user: user)
                BlockUnblock.blockUserInPostsCollection(uid: uid, user: user)
                BlockUnblock.writeBlokedUserInFirestore(postData: postData, secondPostData: secondPostData)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension CommentsHistoryViewController: MFMailComposeViewControllerDelegate {
    private func tappedReportButton(postData: PostData) {
        //       check if the mail can be sent
        if MFMailComposeViewController.canSendMail() == false {
            print("Email Send Failed")
            return
        }

        guard let userEmail = Auth.auth().currentUser?.email else {
            print("メールアドレスの取得失敗")
            return
        }

        let mailViewController = MFMailComposeViewController()
        let toRecipients = ["k-n-t1119@ezweb.ne.jp"]
        let CcRecipients = [userEmail]
        let BccRecipients = [userEmail]

        mailViewController.mailComposeDelegate = self
        mailViewController.setSubject("【通報】投稿内容：\(postData.contentOfPost!)" + "\n" + "\n" + "documentId:\(postData.documentId)\nuid:\(postData.uid!)")
        mailViewController.setToRecipients(toRecipients) // 宛先メールアドレスの表示
        mailViewController.setCcRecipients(CcRecipients)
        mailViewController.setBccRecipients(BccRecipients)
        mailViewController.setMessageBody("内容：(ex.投稿内容が不適切。○○さんの追加コメントが不適切）", isHTML: false)
        mailViewController.title = "【通報】"

        self.present(mailViewController, animated: true, completion: nil)
    }

    private func tappedReportButtonInCommentSection(secondPostData: SecondPostData) {
        //       check if the mail can be sent
        if MFMailComposeViewController.canSendMail() == false {
            print("Email Send Failed")
            return
        }

        guard let userEmail = Auth.auth().currentUser?.email else {
            print("メールアドレスの取得失敗")
            return
        }

        let mailViewController = MFMailComposeViewController()
        let toRecipients = ["k-n-t1119@ezweb.ne.jp"]
        let CcRecipients = [userEmail]
        let BccRecipients = [userEmail]

        mailViewController.mailComposeDelegate = self
        let text = "【通報】投稿内容：\(secondPostData.comment!)" + "\n" + "\n" + "documentId:\(secondPostData.documentId!)\nuid:\(secondPostData.uid!)"
        mailViewController.setToRecipients(toRecipients) // 宛先メールアドレスの表示
        mailViewController.setCcRecipients(CcRecipients)
        mailViewController.setBccRecipients(BccRecipients)
        mailViewController.setMessageBody(text + "\n" + "内容：(ex.投稿内容が不適切。○○さんの追加コメントが不適切）", isHTML: false)
        mailViewController.title = "【通報】"

        self.present(mailViewController, animated: true, completion: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Email Send Cancelled")
        case .saved:
            print("Email Saved as a Draft")
        case .sent:
            print("Email Sent Successfully")
            SVProgressHUD.showSuccess(withStatus: "メールの送信に成功しました")
            SVProgressHUD.dismiss(withDelay: 1.5)
        case .failed:
            print("Email Send Failed")
            SVProgressHUD.showError(withStatus: "メールの送信に失敗しました")
            SVProgressHUD.dismiss(withDelay: 1.5)
            if let error = error {
                print("エラー内容:\(error)")
            }
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

/*
 // MARK: - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
 }
 */
