//
//  DeeplResult.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/08/16.
//

import Foundation

// Codable → API通信で取得したJSONデータをswiftで扱えるようデータ型に変換 → swift用のstructを構築
// Encodable → DeepLResultをJSONにしたい時に使用
struct DeepLResult: Codable {
    let translations: [Translation]

    struct Translation: Codable {
        var detected_source_language: String
        var text: String
    }
}
