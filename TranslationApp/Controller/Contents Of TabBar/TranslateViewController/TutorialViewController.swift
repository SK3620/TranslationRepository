//
//  TutorialViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/09/25.
//

import UIKit

class TutorialViewController: UIViewController {
    
    var collectionView: UICollectionView!
    
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
}

extension TutorialViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func createCollectionView(){
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height - self.navigationController!.navigationBar.frame.height - UIApplication.shared.statusBarFrame.height)
        flowLayout.minimumLineSpacing = 0
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        self.collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.reuseIdentifer)
                
        self.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height), collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0), collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0), collectionView.bottomAnchor.constraint(equalTo: self.pageControl.topAnchor, constant: 0)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.reuseIdentifer, for: indexPath) as! CustomCollectionViewCell
        
        return cell
    }
}
