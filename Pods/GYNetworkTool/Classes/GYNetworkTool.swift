//
//  GYNetworkTool.swift
//  GYNetworkToolDemo
//
//  Created by y g on 2020/12/20.
//

import UIKit
import Alamofire

class GYNetworkTool: NSObject {}

public typealias JSONResponse = [String: Any]
public typealias StringResponse = String
public typealias DataResponse = Data
public typealias SuccessBlock = (JSONResponse?, StringResponse?, DataResponse?) -> Void
public typealias FailureBlock = (Error?) -> Void

public enum GYResponseType {
    case json, string, data
}

extension NSObject {
    
    /// get请求
    @discardableResult public static func get(
        with urlString: String,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        timeoutInterval: TimeInterval = 30.0,
        responseType: GYResponseType = .json,
        success: @escaping SuccessBlock,
        failure: @escaping FailureBlock
    ) -> DataRequest {
        return request(with: urlString, method: .get, parameters: parameters, encoding: encoding, headers: headers, timeoutInterval: timeoutInterval, responseType: responseType, success: success, failure: failure)
    }
    
    /// post请求
    @discardableResult public static func post(
        with urlString: String,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        timeoutInterval: TimeInterval = 30.0,
        responseType: GYResponseType = .json,
        success: @escaping SuccessBlock,
        failure: @escaping FailureBlock
    ) -> DataRequest {
        return request(with: urlString, method: .post, parameters: parameters, encoding: encoding, headers: headers, timeoutInterval: timeoutInterval, responseType: responseType, success: success, failure: failure)
    }
    
    ///put、delete 等请求可以继续添加实现
    
    
    /// 通用请求方法
    /// - Parameters:
    ///   - urlString: 请求地址
    ///   - method: 请求方法
    ///   - parameters: 请求参数
    ///   - encoding: 请求参数编码
    ///   - headers: 请求头
    ///   - timeoutInterval: 超时时长
    ///   - responseType: 返回数据格式类型
    ///   - success: 请求成功的 Task
    ///   - failure: 请求失败的 Task
    @discardableResult public static func request(
        with urlString: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        timeoutInterval: TimeInterval = 30.0,
        responseType: GYResponseType = .json,
        success: @escaping SuccessBlock,
        failure: @escaping FailureBlock) -> DataRequest
    {
        let request = AF.request(urlString, method: method, parameters: parameters, encoding: encoding, headers: headers, requestModifier: { urlRequest in
            urlRequest.timeoutInterval = timeoutInterval
        })

        switch responseType {
            case .json:
                request.responseJSON { (responseJSON) in
                    guard let json = responseJSON.value else {
                        failure(responseJSON.error)
                        return
                    }
                    var responseData = Data()
                    if let data = responseJSON.data {
                        responseData = data
                    }
                    let string = String(data: responseData, encoding: .utf8)
                    success(json as? [String : Any], string, responseJSON.data)
                }
            case .string:
                request.responseString { (responseString) in
                    guard let string = responseString.value else {
                        failure(responseString.error)
                        return
                    }
                    success(nil, string, responseString.data)
                }
            case .data:
                request.responseData { (responseData) in
                    guard let data = responseData.value else {
                        failure(responseData.error)
                        return
                    }
                    let string = String(data: data, encoding: .utf8)
                    success(nil, string, data)
                }
        }
        return request;
    }
}
