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
        
        if
            let cached = NetworkManager.shared.imageCache.object(forKey: url as NSString),
            let image = UIImage(data: cached as Data)
        {
            
            print("Read image from cache")
            completion?(.success(image))
            return
        }
        
        self.downloadFile(at: url, useApiDomain: false) {[weak self] ( result ) in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    self.completion?(.success(image))
                    NetworkManager.shared.imageCache.setObject(data as NSData, forKey: self.url as NSString)
                } else {
                    self.completion?(.failure(DownloadImageError.invalidData))
                }
                break
            case .failure(let error):
                self.completion?(.failure(error))
            }
        }
    }
}
