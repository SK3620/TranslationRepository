//
//  CustomCollectionViewCell.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/09/25.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifer: String = "CustomCell"

    private var underView: UIView!

    // アプリチュートリアル画像の説明テキスト
    var explainLabel: UILabel = {
        let label = UILabel()
        label.textColor = .purple
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    // ImageViewの下にUIViewを生成/設置
    func createUnderViewAndImageView(image: UIImage, collectionView: UICollectionView) {
        // 横幅、縦幅取得
        let screenWidth = self.contentView.frame.width
        let screenHeight = collectionView.frame.height

        // 画像の幅・高さの取得
        let imgWidth = image.size.width
        let imgHeight = image.size.height

        // 画像サイズをスクリーン幅ではなく、スクリーン高さに合わせる
        let scale = screenHeight / imgHeight * 0.75
        let underViewRect = CGRect(x: 0, y: 0,
                                   width: imgWidth * scale + 30, height: imgHeight * scale + 30)
        let imageViewRect = CGRect(x: 0, y: 0,
                                   width: imgWidth * scale, height: imgHeight * scale)

        self.underView = UIView()
        self.underView.frame = underViewRect
        self.underView.center = CGPoint(x: screenWidth / 2, y: screenHeight * 0.5)
        self.underView.layer.cornerRadius = self.underView.frame.size.width * 0.1
        self.underView.clipsToBounds = true
        self.underView.backgroundColor = .systemTeal
        contentView.addSubview(self.underView)

        let imageView = UIImageView(image: image)
        // ImageView frame をCGRectで作った矩形に合わせる
        imageView.frame = imageViewRect
        // 画像の中心を画面の中心に設定
        imageView.center = CGPoint(x: screenWidth / 2, y: screenHeight * 0.5)
        // 角丸にする
        imageView.layer.cornerRadius = imageView.frame.size.width * 0.1
        imageView.clipsToBounds = true
        // UIImageViewのインスタンスをビューに追加
        self.contentView.addSubview(imageView)
    }

    // explainLabelを設置
    func setExplainLabel(collectionView _: UICollectionView) {
        contentView.addSubview(self.explainLabel)

        self.explainLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0).isActive = true
        self.explainLabel.centerYAnchor.constraint(equalTo: self.underView.centerYAnchor, constant: (self.underView.frame.height / 2) * 1.22).isActive = true
        self.explainLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        self.explainLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
