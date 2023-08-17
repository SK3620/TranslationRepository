//
//  TranslateViewModel.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/08/16.
//

import Alamofire
import Foundation
import RxSwift
import SVProgressHUD

class TranslateViewModel {
    private let disposeBag = DisposeBag()
    
    // 日本語 → 英語
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
    
    // 英語 → 日本語
    func translateEngText(text: String, completion: @escaping (Result<DeepLResult, Error>) -> Void) {
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
                    completion(Result<DeepLResult, Error>.success(result))
                    // エラーが発生した場合
                } catch let error {
                    debugPrint("デコード失敗\(error.localizedDescription)")
                    completion(Result<DeepLResult, Error>.failure(error))
                }
            case .failure(let error as! Error):
                print("APIリクエストエラー\(error.localizedDescription)")
                completion(Result<DeepLResult, Error>.failure(error as! Error))
            }
        }
    }
}
    /*
        
        

        //　Almofire → API情報を取得するための便利なライブラリ　swiftで用意されているURLSessionもある
        // リクエスト成功か判定　encoder: URLEncodedFormParameterEncoder.default
        AF.request("https://api.deepl.com/v2/translate", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: headers).responseDecodable(of: DeepLResult.self) { response in
            // リクエスト結果response.resultにはsuccessのDeeplResult型/failureのAFError型のデータのどちらかが格納
            // switch構文の場合
            switch response.result {
            case let .success(data):
                let translationResult: Result<DeepLResult, AFError> = .success(data)
                completion(translationResult, response.data)
            case let .failure(afError):
                let afError: Result<DeepLResult, AFError> = .failure(afError)
                completion(afError, nil)
            }
        }
    }
    /*
     今回はResult<Success, Failure: Error>の使い方の練習のためわざと使用してるが、以下の方が簡潔
    func translateEngText(text: String, completion: @escaping (DataResponse<DeepLResult, AFError>) -> Void) {
        // 省略
        AF.request("https://api.deepl.com/v2/translate", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: headers).responseDecodable(of: DeepLResult.self) { response in
            completion(response)
            // あとは、ViewControllerで、if case .success/.failure = response.resultで条件分岐 + do try catchで結果をデコード + UIに反映
        }
    }
    */
                                          // または
     func translateEngText(text: String, completion: @escaping (DeepLResult) -> Void) {
         // 省略
         AF.request("https://api.deepl.com/v2/translate", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: headers).responseDecodable(of: DeepLResult.self) { response in
             if case .success = response.result {
                 do {
                     let result: DeepLResult = try self.decoder.decode(DeepLResult.self, from: response.data!)
                     completion(result)
                     //あとは、ViewControllerで ↓
                     let text = result.translations[0].text.trimmingCharacters(in: .whitespaces)
                     self.translateTextView2.text = text
                     UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                     SVProgressHUD.showSuccess(withStatus: "翻訳完了")
                     SVProgressHUD.dismiss(withDelay: 1.5)
                     // エラーが発生した場合
                 } catch let error {
                     debugPrint("デコード失敗\(error.localizedDescription)")
                     SVProgressHUD.showError(withStatus: "翻訳できませんでした")
                 }
             } else {
                 let afError: AFError = response.error
                 debugPrint("APIリクエストエラー\(aferror.localizedDescription)")
                 SVProgressHUD.showError(withStatus: "翻訳できませんでした")
             }
         }
     }
}

    
     */
