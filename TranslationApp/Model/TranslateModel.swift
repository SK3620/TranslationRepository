//
//  TranslateModel.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/08/16.
//

import Alamofire
import Foundation
import RxSwift
import SVProgressHUD

class TranslateModel {
    private let disposeBag = DisposeBag()

    // 日本語 → 英語 RxSwiftを使用してみる
    func translateJpText(text: String) -> Observable<DeepLResult> {
        SVProgressHUD.show(withStatus: "翻訳中")

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
        let deeplResultObservable = Observable<DeepLResult>.create { observer in
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
                request.cancel() // deeplResultObservableの終了後、不要なネットワークリクエストを行わないようにする
            }
        }

        return deeplResultObservable
    }

    // エラーに引数(引数ラベルも）を持たせられる
    enum TranslationError: Error {
        case decodeError(decodeError: Error) // 引数としてError型も受け取り、一緒に渡す
        case apiRequestError(apiRequestError: Error, errorMessage: String) // 引数としてString型も受け取る
    }

    // 英語 → 日本語 do try catch構文・Result<Success, Failure: Error> を使用してみる
    func translateEngText(text: String, completion: @escaping (Result<DeepLResult, TranslationError>) -> Void) {
        SVProgressHUD.show(withStatus: "翻訳中")
        var authKey = KeyManager().getValue(key: "apiKey") as! String

        //            前後のスペースと改行を削除
        authKey = authKey.trimmingCharacters(in: .newlines)

        // APIリクエストするパラメータを作成　リクエストするために必要な情報を定義　リクエスト成功時に、翻訳結果が返される
        let parameters: [String: String] = [
            "text": text,
            "auth_key": authKey,
            "source_lang": "EN",
            "target_lang": "JA",
        ]

        // ヘッダーを作成
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
        ]

        AF.request("https://api.deepl.com/v2/translate", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: headers).responseDecodable(of: DeepLResult.self) { response in
            switch response.result {
            case .success:
                do {
                    // do節でエラー返ってくる可能性のあるメソッドを書く → .decodeでthrowsが使用されてる → try
                    // JSONデータを指定した型にデコード
                    // APIから取得したJSON翻訳結果をデコードし、DeeplResult型のデータを生成
                    // DeepLResult.self → DeeplResult型そのものを取得　→ プロパティやメソッドにアクセス可能/インスタンス作成可能
                    let result: DeepLResult = try JSONDecoder().decode(DeepLResult.self, from: response.data!)
                    completion(Result<DeepLResult, TranslationError>.success(result))
                    // エラーが発生した場合
                } catch {
                    debugPrint("デコード失敗\(error.localizedDescription)")
                    completion(Result<DeepLResult, TranslationError>.failure(.decodeError(decodeError: error)))
                }
            case let .failure(error as Error):
                completion(Result<DeepLResult, TranslationError>.failure(.apiRequestError(apiRequestError: error, errorMessage: "APIリクエストエラー")))
            }
        }
    }
}
