//
//  ClientApiService.swift
//  RTestApp
//
//  Created by Viacheslav Obremskyi on 03.11.2020.
//

import Foundation

enum ClientApiServiceError : Error {
    case cantParseFile
    case invalidUrl
}

class ClientApiService : NSObject {
    
    private var task : URLSessionTask?
    private var _taskCompletion: ((Result<Data, Error>)->())?
    
    func start() {}
    
    func cancel() {
        self.task?.cancel()
        _taskCompletion = nil
    }
    
     func sendGETRequest(at path: String,
                        withHeaders headers: [String : String]? = nil,
                        useFullPath : Bool = false,
                        completion: ((Result<Data, Error>)->())?) {
        
        let urlString = useFullPath ? path : self.baseUrl + path
        
        guard let url = URL(string: urlString), url.isValid  else {
            _taskCompletion?(.failure(ClientApiServiceError.invalidUrl))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        self._taskCompletion = completion
        self.task = createTaskWithRequest(request)
    }
    
    func downloadFile(at path: String,
                      useApiDomain : Bool,
                        completion: ((Result<Data, Error>)->())?) {
        
        let urlString = useApiDomain ? self.baseUrl + path : path
        
        guard let url = URL(string: urlString), url.isValid  else {
            _taskCompletion?(.failure(ClientApiServiceError.invalidUrl))
            return
        }
        let request = URLRequest(url: url)
        self._taskCompletion = completion
        self.task = downloadFile(request, config: .basic)
    }

    
    private var baseUrl : String{
        return NetworkManager.shared.environment.apiUrl
    }
    
    private func createTaskWithRequest(_ request: URLRequest, config: NetworkManager.Configuration = .basic) -> URLSessionTask {
        let task = NetworkManager.shared.session(with: config).dataTask(with: request) { (data, _, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self._taskCompletion?(Result.failure(error))
                    return
                }
                
                if let data = data {
                    self._taskCompletion?(Result.success(data))
                }
            }
        }
        task.resume()
        return task
    }
    
    private func downloadFile(_ request: URLRequest, config: NetworkManager.Configuration = .basic) -> URLSessionTask {
        let task = NetworkManager.shared.session(with: config).downloadTask(with: request) { (url, response, error) in
            
            DispatchQueue.main.async {
                if let error = error {
                    self._taskCompletion?(Result.failure(error))
                    return
                }
                
                if let url = url {
                    do {
                        let data = try Data(contentsOf: url)
                        self._taskCompletion?(Result.success(data))
                    }catch {
                        self._taskCompletion?(Result.failure(error))
                    }
                }
            }
        }
        
        task.resume()
        return task
    }
}
