//
//  ChatViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/12/16.
//

import Firebase
import FirebaseStorageUI
import InputBarAccessoryView
import MessageKit
import SVProgressHUD
import UIKit

class ChatRoomViewController: MessagesViewController {
    var chatListData: ChatList!
    var secondTabBarController: SecondTabBarController!

    private var listener: ListenerRegistration?
    private var chatRoomArr: [ChatRoom] = []

    private var currentUser: MessageSenderType?
    private var partnerUser: MessageSenderType?

    private var messageList: [MessageEntity] = [] {
        didSet {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarAppearence()

        self.setDelegateMethod()

        let myUid = self.getMyUidAndPartnerUid(chatListData: self.chatListData).first
        let partnerUid = self.getMyUidAndPartnerUid(chatListData: self.chatListData)[1]

        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.image = UIImage(systemName: "paperplane")

        let myName = self.getMyNameAndPartnerName().first!
        let partnerName = self.getMyNameAndPartnerName()[1]
        self.currentUser = MessageSenderType.mymessageSenderType(mySenderId: "Me", myDisplayName: myName)
        self.partnerUser = MessageSenderType.partnerMessageSenderType(partnerSenderId: "partner", partnerDisplayName: partnerName)

        self.title = partnerName
    }

    private func setDelegateMethod() {
        messagesCollectionView.backgroundColor = UIColor.secondarySystemBackground
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        messageInputBar.delegate = self
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.image = UIImage(systemName: "paperplane")
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        self.setNavigationBarHidden()
        GetDocument.getMessagesDocument(chatListData: self.chatListData, listener: self.listener) { messageList, chatRoomArr in
            self.messageList = messageList
            self.chatRoomArr = chatRoomArr

            self.createMessage()
        }
    }

    private func createMessage() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        for chatRoomData in self.chatRoomArr {
            if chatRoomData.senderUid == user.uid {
                self.messageList.append(MessageEntity.createMyMessage(userName: self.getMyNameAndPartnerName().first!, text: chatRoomData.message!, sender: self.currentUser!, messageId: "0", sentDate: chatRoomData.sentDate!))
            } else {
                self.messageList.append(MessageEntity.createPartnerMessage(userName: self.getMyNameAndPartnerName()[1], text: chatRoomData.message!, sender: self.partnerUser!, messageId: "0", sentDate: chatRoomData.sentDate!))
            }
            self.messagesCollectionView.reloadData()
        }
    }

    private func setNavigationBarHidden() {
        self.secondTabBarController.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func setNavigationBarAppearence() {
        let appearence = UINavigationBarAppearance()
        appearence.backgroundColor = .systemGray6
        self.navigationController?.navigationBar.standardAppearance = appearence
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearence
    }

    private func getMyNameAndPartnerName() -> [String] {
        let user = Auth.auth().currentUser!
        var chatMembersFirstIsMyName: Bool
        if self.chatListData.chatMembersName?.first == user.displayName {
            chatMembersFirstIsMyName = true
        } else {
            chatMembersFirstIsMyName = false
        }
        var partnerName = ""
        var myName = ""
        switch chatMembersFirstIsMyName {
        case true:
            partnerName = (self.chatListData.chatMembersName?[1])!
            myName = (self.chatListData.chatMembersName?.first)!
        case false:
            partnerName = (self.chatListData.chatMembersName?.first)!
            myName = (self.chatListData.chatMembersName?[1])!
        }
        return [myName, partnerName]
    }

    private func getMyUidAndPartnerUid(chatListData: ChatList) -> [String] {
        let user = Auth.auth().currentUser
        var chatMembersFirstisMyUid: Bool
        if chatListData.chatMembers?.first == user?.uid {
            chatMembersFirstisMyUid = true
        } else {
            chatMembersFirstisMyUid = false
        }
        var myUid = ""
        var partnerUid = ""
        switch chatMembersFirstisMyUid {
        case true:
            myUid = (chatListData.chatMembers?.first!)!
            partnerUid = chatListData.chatMembers![1]
        case false:
            myUid = chatListData.chatMembers![1]
            partnerUid = (chatListData.chatMembers?.first!)!
        }
        return [myUid, partnerUid]
    }

    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.secondTabBarController.navigationController?.setNavigationBarHidden(false, animated: false)
        self.listener?.remove()
    }
}

extension ChatRoomViewController: InputBarAccessoryViewDelegate {
    func inputBar(_: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard text.isEmpty != true else {
            SVProgressHUD.showError(withStatus: "メッセージを入力してください")
            SVProgressHUD.dismiss(withDelay: 1.5)
            return
        }
        messageInputBar.inputTextView.text = String()
        WritingData.writeMessageData(text: text, chatListData: self.chatListData)
    }

    func getToday() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        // DateFormatter を使用して書式とロケールを指定する
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy.M.d HH:mm", options: 0, locale: Locale(identifier: "ja_JP"))
        let today = dateFormatter.string(from: date)
        return today
    }
}

extension ChatRoomViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        print("currentSender")
        return self.currentUser!
    }

    func numberOfSections(in _: MessagesCollectionView) -> Int {
        print(self.messageList.count)
        return self.messageList.count
    }

    func messageForItem(at indexPath: IndexPath, in _: MessagesCollectionView) -> MessageType {
        return self.messageList[indexPath.section]
    }

    func messageTopLabelAttributedText(for _: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(
            string: self.messageList[indexPath.section].userName,
            attributes: [.font: UIFont.systemFont(ofSize: 12.0),
                         .foregroundColor: UIColor.systemBlue]
        )
    }

    func messageBottomLabelAttributedText(for _: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(
            string: self.messageList[indexPath.section].stringSentDate,
            attributes: [.font: UIFont.systemFont(ofSize: 12.0),
                         .foregroundColor: UIColor.secondaryLabel]
        )
    }
}

// MARK: MessagesDisplayDelegate

extension ChatRoomViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor.systemBlue : UIColor.systemBackground
    }

    func messageStyle(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }

    func configureAvatarView(_ avatarView: AvatarView, for _: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) {
        let user = Auth.auth().currentUser!
        let senderUid = self.chatRoomArr[indexPath.section].senderUid
        if user.uid == senderUid {
            if let myPartnerImageUrl = self.chatListData.myProfileImageUrl {
                avatarView.sd_setImage(with: myPartnerImageUrl, placeholderImage: nil, options: SDWebImageOptions.refreshCached, context: nil)
            } else {
                avatarView.image = UIImage(systemName: "person")
            }
        } else {
            if let partnerImageUrl = self.chatListData.partnerProfileImageUrl {
                avatarView.sd_setImage(with: partnerImageUrl, placeholderImage: nil, options: SDWebImageOptions.refreshCached, context: nil)
            } else {
                avatarView.image = UIImage(systemName: "person")
            }
        }
    }
}

// MARK: MessagesLayoutDelegate

extension ChatRoomViewController: MessagesLayoutDelegate {
    func headerViewSize(for _: Int, in _: MessagesCollectionView) -> CGSize {
        return CGSize.zero
    }

    func messageTopLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        return 24
    }

    func messageBottomLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        return 24
    }
}
