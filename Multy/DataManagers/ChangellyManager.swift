//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation
import Alamofire
import CommonCryptoSwift

typealias ChangellyManager = ApiManager

let changellyURL = "https://api.changelly.com"
let apiKey = "e277668dacd24629836b4c5f289aa52d"
let secretKey = "57ef86f42d6790fc9b02f281a43e500a5639f067e4b25dc043240d891fc4e400"

extension ChangellyManager {
    func getChangellyCurrencies(completion: @escaping(_ answer: Result<NSDictionary, String>) -> ()) {
        createChangellyRequest(method: "getCurrencies", parameters: [:]) { completion($0) }
    }
    
    func  getStatus(of transactionID: String, completion: @escaping(_ answer: Result<NSDictionary, String>) -> ()) {
        let params: Parameters = [
            "id":  transactionID
        ]
        
        createChangellyRequest(method: "getStatus", parameters: params) { completion($0) }
    }
    
    func createChangellyRequest(method: String, parameters: Parameters, completion: @escaping(_ answer: Result<NSDictionary, String>) -> ())  {
        let params: Parameters = [
            "jsonrpc":  "2.0",
            "id":       "1",
            "method":   method,
            "params":  parameters
        ]
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "api-key":      apiKey,
            "sign":         createSign(params: params)
        ]
        
        requestManager.request("\(changellyURL)", method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).validate().debugLog().responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                if response.result.value != nil {
                    completion(Result.success(response.result.value as! NSDictionary))
                } else {
                    completion(Result.failure("Error"))
                }
            case .failure(let error):
                completion(Result.failure(error.localizedDescription))
                break
            }
        }
    }
    
    func createSign(params: Parameters) -> String  {
        if let theJSONData = try? JSONSerialization.data(withJSONObject: params,
                                                         options: []) {
            let theJSONText = String(data: theJSONData, encoding: .ascii)
            print("JSON string = \(theJSONText!)")
            
            let sign = HMAC.SHA512(string: theJSONText!, key: secretKey)
            
            return sign!
        } else {
            return ""
        }
    }
}
