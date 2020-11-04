//
//  DownloadImageService.swift
//  RTestApp
//
//  Created by Viacheslav Obremskyi on 04.11.2020.
//

import UIKit

enum DownloadImageError : Error {
    case invalidData
}

class DownloadImageService: ClientApiService {
    
    let url : String
    var completion : ((Result<UIImage,Error>)->())?
    
    init(url : String, completion : ((Result<UIImage,Error>)->())?) {
        self.url = url
        self.completion = completion
        super.init()
    }
    
    override func start() {
        super.start()
        self.downloadFile(at: url, useApiDomain: false) {[weak self] ( result ) in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    self?.completion?(.success(image))
                } else {
                    self?.completion?(.failure(DownloadImageError.invalidData))
                }
                break
            case .failure(let error):
                self?.completion?(.failure(error))
            }
        }
    }
}
