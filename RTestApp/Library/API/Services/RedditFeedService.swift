//
//  RedditFeedService.swift
//  RTestApp
//
//  Created by md760 on 03.11.2020.
//

import UIKit

class RedditFeedService: ClientApiService {

    var completion : ((Result<[RedditFeedItem], Error>)->())?
    
    init (completion : ((Result<[RedditFeedItem], Error>)->())?) {
        self.completion = completion
        super.init()
    }
    
    override func start() {
                
        downloadFile(at: "top.json", useApiDomain: true) { [weak self] (result) in
            switch result {
            case .success(let data):
                do {
                    let feed = try JSONDecoder().decode(RedditFeedItemsList.self, from: data)
                    self?.completion?(.success(feed.items))
                }catch{
                    self?.completion?(.failure(error))
                }
                
            case .failure(let error):
                self?.completion?(.failure(error))
            }
        }
    }
}
