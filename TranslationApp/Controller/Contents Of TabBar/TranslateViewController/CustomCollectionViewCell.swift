//
//  CustomCollectionViewCell.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/09/19.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "CustomCell"

    // アプリ説明画像用のimageView生成
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // 説明テキスト用のlable生成
    let usageNumLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 40, weight: .heavy)
        label.textColor = .systemOrange
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame) // CustomCollectionViewCellのイニシャライザ内で、親クラスであるUICollectionViewCellのイニシャライザを呼び出す　.zeroと指定 → カスタムセルの初期化時には特定のフレームを持たないことを示す → 実際のセルのサイズや位置は、コレクションビューのレイアウトによって設定。

        // cellの外観設定
        contentView.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.075)
        contentView.layer.cornerRadius = 30
        contentView.layer.borderColor = UIColor.systemBlue.cgColor
        contentView.layer.borderWidth = 1.0

        // imageViewをcellに追加
        contentView.addSubview(self.imageView)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            self.imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            self.imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
        ])

        // usageLableをcellに追加
        contentView.addSubview(self.usageNumLabel)
        self.usageNumLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.usageNumLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            self.usageNumLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -50),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
