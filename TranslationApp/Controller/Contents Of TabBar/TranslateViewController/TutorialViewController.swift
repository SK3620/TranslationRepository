//
//  TutorialViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/09/25.
//

import UIKit

class TutorialViewController: UIViewController {
    var collectionView: UICollectionView!

    let pageControl: UIPageControl = {
        let pageCotrol = UIPageControl()
        pageCotrol.translatesAutoresizingMaskIntoConstraints = false
        pageCotrol.currentPage = 0
        pageCotrol.numberOfPages = 8
        pageCotrol.currentPageIndicatorTintColor = UIColor.systemMint
        pageCotrol.pageIndicatorTintColor = .systemGray4
        pageCotrol.isEnabled = false
        return pageCotrol
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarButtonItem()
        self.setPageControl()
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

    // pageControl設置
    func setPageControl() {
        self.view.addSubview(self.pageControl)

        NSLayoutConstraint.activate([
            self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0), self.pageControl.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            self.pageControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0), self.pageControl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
        ])
    }
}

extension TutorialViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func createCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height - self.navigationController!.navigationBar.frame.height - UIApplication.shared.statusBarFrame.height)
        flowLayout.minimumLineSpacing = 0

        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        self.collectionView.isScrollEnabled = false
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.reuseIdentifer)

        self.view.addSubview(self.collectionView)

        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height), self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0), self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0), self.collectionView.bottomAnchor.constraint(equalTo: self.pageControl.topAnchor, constant: 0),
        ])
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.reuseIdentifer, for: indexPath) as! CustomCollectionViewCell

        return cell
    }
}
