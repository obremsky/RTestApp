//
//  RedditFeedService.swift
//  RTestApp
//
//  Created by md760 on 03.11.2020.
//

import UIKit

class RedditFeedService: ClientApiService {
    
    let count : Int
    private var last: RedditFeedItem?
    var completion : ((Result<[RedditFeedItem], Error>)->())?
    
    init (count: Int, before : RedditFeedItem? = nil, completion : ((Result<[RedditFeedItem], Error>)->())?) {
        self.completion = completion
        self.count = count
        super.init()
    }
    
    override func start() {
       loadNext()
    }
    
    private func loadNext() {
        var url = "top.json?count=\(count)"
        if let last = last {
            url += "&before=\(last.name)"
        }
        
        sendGETRequest(at: "top.json?limit=50") {[weak self] (result) in
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
