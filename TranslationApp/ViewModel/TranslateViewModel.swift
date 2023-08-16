//
//  TranslateViewModel.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/08/16.
//

import Foundation
import RxSwift
import Alamofire

class TranslateViewModel {
    private let disposeBag = DisposeBag()
    
    func translateText(text: String) -> Observable<DeepLResult> {
        var authKey = KeyManager().getValue(key: "apiKey") as! String
        
        authKey = authKey.trimmingCharacters(in: .newlines)
        
        let parameters: [String: String] = [
            "text": text,
            "auth_key": authKey,
            "source_lang": "JA",
            "target_lang": "EN",
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
        ]
        
        // .createメソッドで、独自のDeepLResultという型の結果を非同期に取得するストリームを作成
        let translationObservable = Observable<DeepLResult>.create { observer in
            // この"observer"は.onNextや.onErrorなどのメソッドを使用して、仲介役として非同期処理の結果やエラーなどを、作成した独自のObservable<DeepLResult>ストリームに通知
            let request = AF.request("https://api.deepl.com/v2/translate", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: headers).responseDecodable(of: DeepLResult.self) { response in
                if case .success = response.result, let data = response.data {
                    do {
                        let result: DeepLResult = try JSONDecoder().decode(DeepLResult.self, from: data)
                        observer.onNext(result) // 非同期処理の結果（イベント情報）をObservable<DeepLResult>というストリームに流す
                        observer.onCompleted() // 非同期処理の完了を通知/ストリームに流す
                    } catch {
                        observer.onError(error) // 非同期処理でのエラーを通知 (購読が解除される)
                    }
                } else {
                    observer.onError(response.error ?? NSError()) // APIリクエストエラーの通知
                }
            }

            return Disposables.create {
                // 購読解除後の処理
                request.cancel() // translationObservableの終了後、不要なネットワークリクエストを行わないようにする
            }
        }
        
        return translationObservable
    }
}
