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

    // 右隣のcollectionViewCellに横スクロールさせるbutton
    let forwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .medium)
        button.setImage(UIImage(systemName: "arrow.forward", withConfiguration: config), for: .normal)
        return button
    }()

    // 左隣のcollectionViewCellに横スクロールさせるbutton
    let backwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .medium)
        button.setImage(UIImage(systemName: "arrow.backward", withConfiguration: config), for: .normal)
        return button
    }()
    
    // アプリチュートリアル画像8枚
    let imageArr = [UIImage(named: "IMG_3231"), UIImage(named: "IMG_3232"),UIImage(named: "IMG_3241"), UIImage(named: "IMG_3233"),UIImage(named: "IMG_3234"), UIImage(named: "IMG_3235"),UIImage(named: "IMG_3236"), UIImage(named: "IMG_3237")]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarButtonItem()
        self.setPageControl()
        self.createCollectionView()
        self.createGradientLayer()
        self.setForwardButton()
        self.setBackwardButton()
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

    // self.viewの背景をグラデーション
    func createGradientLayer() {
        // グラデーションレイヤーを作成
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds // UIViewと同じサイズに設定
        let lightBlue = UIColor(red: 173 / 255.0, green: 216 / 255.0, blue: 230 / 255.0, alpha: 1.0)

        gradientLayer.colors = [lightBlue.cgColor, UIColor.white.cgColor] // 開始色と終了色を設定
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0) // グラデーションの開始位置（左上）
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0) // グラデーションの終了位置（右下）

        // UIViewにグラデーションレイヤーを追加
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // forwardButtonの設置
    func setForwardButton() {
        self.view.addSubview(self.forwardButton)

        NSLayoutConstraint.activate([
            self.forwardButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.forwardButton.centerYAnchor.constraint(equalTo: self.pageControl.centerYAnchor),
        ])

        self.forwardButton.addTarget(self, action: #selector(self.tapButton(_:)), for: .touchUpInside)
    }

    // backwardButtonの設置
    func setBackwardButton() {
        self.view.addSubview(self.backwardButton)

        NSLayoutConstraint.activate([
            self.backwardButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.backwardButton.centerYAnchor.constraint(equalTo: self.pageControl.centerYAnchor),
        ])

        self.backwardButton.addTarget(self, action: #selector(self.tapButton(_:)), for: .touchUpInside)
    }

    @objc func tapButton(_: UIButton) {}
}

extension TutorialViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func createCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height - self.navigationController!.navigationBar.frame.height - UIApplication.shared.statusBarFrame.height)
        flowLayout.minimumLineSpacing = 0

        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        self.collectionView.isScrollEnabled = false
        self.collectionView.backgroundColor = .clear
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
        return self.imageArr.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.reuseIdentifer, for: indexPath) as! CustomCollectionViewCell

        return cell
    }
}
