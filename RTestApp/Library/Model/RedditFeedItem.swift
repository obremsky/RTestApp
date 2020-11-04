//
//  RedditFeedItem.swift
//  RTestApp
//
//  Created by md760 on 03.11.2020.
//

import UIKit

class RedditFeedItemsList : NSObject, Decodable {
    
    let items : [RedditFeedItem]

    class JsonData : Decodable {
        let items : [RedditFeedItem]
        enum CodingKeys: String, CodingKey {
            case data = "children"
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            items = try container.decode([RedditFeedItem].self, forKey: .data)
        }
    }

    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(JsonData.self, forKey: .data)
        items = data.items
    }
}

class RedditFeedItem: NSObject, Decodable {
    
    class UserReview : NSObject, Decodable {}
    
    let author : String
    let title : String
    var thumbnail : String?
    var reviews : [UserReview]?
    
    class JsonData : Decodable {
        let title: String
        let author : String
        var thumbnail : String?
        var reviews : [UserReview]
        enum CodingKeys: String, CodingKey {
            case title
            case thumbnail
            case author = "author_fullname"
            case reviews = "all_awardings"
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decode(String.self, forKey: .title)
            author = try container.decode(String.self, forKey: .author)
            thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
            reviews = try container.decode([UserReview].self, forKey: .reviews)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "data"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(JsonData.self, forKey: .name)
        
        title = data.title
        author = data.author
        reviews = data.reviews
        thumbnail = data.thumbnail
    }
}
