//
//  TutorialViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/09/25.
//

import UIKit

class TutorialViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarButtonItem()
    }

    // navigationBarに閉じるボタン
    func setNavigationBarButtonItem() {
        let closeButtonImage = UIImage(systemName: "xmark") // close_iconはアイコン画像の名前
        let closeButton = UIBarButtonItem(image: closeButtonImage, style: .plain, target: self, action: #selector(self.closeButtonTapped))
        self.navigationItem.rightBarButtonItem = closeButton
    }

    @objc func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
