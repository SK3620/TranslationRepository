//
//  BlockUnblock.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/01/26.
//

import Firebase
import Foundation
import SVProgressHUD
import UIKit

struct BlockUnblock {
    static func ifYouCanCommentOnThePost(postData: PostData, user: User, completion: @escaping (Bool) -> Void) {
        let blockRef = Firestore.firestore().collection(FireBaseRelatedPath.blocking).whereField("blockedUser", isEqualTo: user.uid).whereField("blockedBy", isEqualTo: postData.uid!)
        blockRef.getDocuments(completion: { querySnapshot, error in
            if let error = error {
                print("エラーです\(error)")
            }
            if let querySnapshot = querySnapshot {
                if querySnapshot.documents.isEmpty {
                    print("あなたはブロックされていないため、コメントできます")
                    completion(true)
                } else {
                    print("あなたはブロックされているため、コメントできません")
                    SVProgressHUD.showError(withStatus: "あなたは'\(postData.userName!)'さんによってブロックされているため、コメントできません")
                    SVProgressHUD.dismiss(withDelay: 2.5) {
                        completion(false)
                    }
                }
            }
        })
    }

//    check if you are being blocked by other users when they press the post button
//    if the "blockedUser" in "blocking" collection is your uid, retrive the documents whose key ("blockedUser") is your uid
    static func determineIfYouAreBeingBlocked(completion: @escaping ([String]) -> Void) {
        let user = Auth.auth().currentUser!
        let blockRef = Firestore.firestore().collection(FireBaseRelatedPath.blocking).whereField("blockedUser", isEqualTo: user.uid)
        blockRef.getDocuments(completion: { querySnapshot, error in
            if let error = error {
                print("エラー\(error)")
            }
            if let querySnapshot = querySnapshot {
                var excuteClosureWhenZero: Int = querySnapshot.documents.count
                if querySnapshot.documents.isEmpty {
                    print("誰からもブロックされていない")
                    completion([])
                    return
                }
                var blockedBy: [String] = []
                querySnapshot.documents.forEach {
                    queryDocumentSnapshot in
                    excuteClosureWhenZero = excuteClosureWhenZero - 1
                    let blockData = BlockData(document: queryDocumentSnapshot)
                    blockedBy.append(blockData.blockedBy!)
                    if excuteClosureWhenZero == 0 {
                        completion(blockedBy)
                    }
                }
            }
        })
    }

    static func determineIfYouCanAddFriend(uid: String, userName: String, completion: @escaping () -> Void) {
        let user = Auth.auth().currentUser!
        let blockRef = Firestore.firestore().collection(FireBaseRelatedPath.blocking).whereField("blockedUser", isEqualTo: user.uid).whereField("blockedBy", isEqualTo: uid)
        blockRef.getDocuments(completion: { querySnapshot, error in
            if let error = error {
                print("エラー\(error)")
            }
            if let querySnapshot = querySnapshot {
                if querySnapshot.documents.isEmpty {
                    print("あなたはまだブロックされていません")
                    completion()
                } else {
                    print("すでにあなたはブロックされている")
                    SVProgressHUD.showError(withStatus: "あなたは'\(userName)'さんによってブロックされているため友達追加できません")
                    SVProgressHUD.dismiss(withDelay: 2.5)
                }
            }
        })
    }

    static func determineIfHasAlreadyBeenBlocked(uid: String, completion: @escaping () -> Void) {
        let user = Auth.auth().currentUser!
        let blockRef = Firestore.firestore().collection(FireBaseRelatedPath.blocking).whereField("blockedBy", isEqualTo: user.uid).whereField("blockedUser", isEqualTo: uid)
        blockRef.getDocuments(completion: { querySnapshot, error in
            if let error = error {
                print("エラー\(error)")
            }
            if let querySnapshot = querySnapshot {
                if querySnapshot.documents.isEmpty {
                    completion()
                } else {
                    print("からなので、すでにブロック済み")
                    SVProgressHUD.showError(withStatus: "すでにブロックされています")
                    SVProgressHUD.dismiss(withDelay: 1.5)
                }
            }
        })
    }

    static func blockUserInCommentsCollection(uid: String, user: User) {
        let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("uid", isEqualTo: uid)
        commentsRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("エラー\(error)")
            }
            if let querySnapshot = querySnapshot {
                if querySnapshot.documents.isEmpty {
                    print("からでした")
                    return
                }
                querySnapshot.documents.forEach { queryDocumentSnapshot in
                    let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).document(queryDocumentSnapshot.documentID)
                    let updateValue = FieldValue.arrayUnion([user.uid])
                    commentsRef.updateData(["blockedBy": updateValue])
                }
            }
        }
    }

    static func blockUserInPostsCollection(uid: String, user: User) {
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("uid", isEqualTo: uid)
        postsRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("エラー\(error)")
            }
            if let querySnapshot = querySnapshot {
                if querySnapshot.documents.isEmpty {
                    print("からでした")
                    return
                }
                querySnapshot.documents.forEach { queryDocumentSnapshot in
                    let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(queryDocumentSnapshot.documentID)
                    let updateValue = FieldValue.arrayUnion([user.uid])
                    postsRef.updateData(["blockedBy": updateValue])
                }
            }
        }
    }

    static func writeBlokedUserInFirestore(postData: PostData?, secondPostData: SecondPostData?) {
        let user = Auth.auth().currentUser!
        let blockingRef = Firestore.firestore().collection(FireBaseRelatedPath.blocking).document()

        var userName = ""
        var blockedUser = ""
        var profileImageUrlString = "nil"
        if let postData = postData {
            userName = postData.userName!
            blockedUser = postData.uid!
            if let url = postData.profileImageUrl {
                profileImageUrlString = url.absoluteString
            }
        }

        if let secondPostData = secondPostData {
            userName = secondPostData.userName!
            blockedUser = secondPostData.uid!
            if let url = secondPostData.profileImageUrl {
                profileImageUrlString = url.absoluteString
            }
        }

        let blockingDic = [
            "userName": userName,
            "blockedBy": user.uid,
            "blockedUser": blockedUser,
            "blockedDate": FieldValue.serverTimestamp(),
            "profileImageUrlString": profileImageUrlString,
        ] as [String: Any]

        blockingRef.setData(blockingDic) { error in
            if let error = error {
                print("エラー\(error)")
            } else {
                print("書き込み成功しました")
            }
        }
    }

//    in BlockListVC
    static func getDocumentOfBlockedUser(user: User, listener: ListenerRegistration?, completion: @escaping ([BlockData]) -> Void) {
        SVProgressHUD.show(withStatus: "データを取得中...")
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.blocking).whereField("blockedBy", isEqualTo: user.uid).order(by: "blockedDate", descending: true)
        var listener = listener
        listener = postsRef.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("エラー\(error)")
                SVProgressHUD.dismiss()
            }
            if let querySnapshot = querySnapshot {
                var blockArray: [BlockData] = []
                if querySnapshot.documents.isEmpty {
                    completion(blockArray)
                    return
                }
                querySnapshot.documents.forEach { queryDocumentSnapshot in
                    blockArray.append(BlockData(document: queryDocumentSnapshot))
                    completion(blockArray)
                }
            }
        }
    }

//    in BlockListVC
    static func unblockUser(blockData: BlockData) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        let blockRef = Firestore.firestore().collection(FireBaseRelatedPath.blocking).document(blockData.documentId)
        blockRef.delete { error in
            if let error = error {
                print("エラー\(error)")
            } else {
                print("削除成功")
                self.unblockUser2(blockData: blockData, user: user)
                self.unblockUser3(blockData: blockData, user: user)
            }
        }
    }

    //    in BlockListVC
    static func unblockUser2(blockData: BlockData, user: User) {
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("uid", isEqualTo: blockData.blockedUser!).whereField("blockedBy", arrayContains: user.uid)
        postsRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("エラー\(error)")
            }
            if let querySnapshot = querySnapshot {
                if querySnapshot.documents.isEmpty {
                    return
                }
                querySnapshot.documents.forEach { queryDocumentSnapshot in
                    let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(queryDocumentSnapshot.documentID)
                    let updatedValue = FieldValue.arrayRemove([user.uid])
                    postsRef.updateData(["blockedBy": updatedValue])
                }
            }
        }
    }

    //    in BlockListVC
    static func unblockUser3(blockData: BlockData, user: User) {
        let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("uid", isEqualTo: blockData.blockedUser!).whereField("blockedBy", arrayContains: user.uid)
        commentsRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("エラー\(error)")
            }
            if let querySnapshot = querySnapshot {
                if querySnapshot.documents.isEmpty {
                    return
                }
                querySnapshot.documents.forEach { queryDocumentSnapshot in
                    let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).document(queryDocumentSnapshot.documentID)
                    let updatedValue = FieldValue.arrayRemove([user.uid])
                    commentsRef.updateData(["blockedBy": updatedValue])
                }
            }
        }
    }
}