//
//  NetworkManager.swift
//  RTestApp
//
//  Created by Viacheslav Obremskyi on 03.11.2020.
//

import Foundation

class NetworkManager : NSObject {
    
    enum Configuration {
        case basic
    }
    
    static let shared = NetworkManager()
    
    var imageCache: NSCache<NSString, NSData> = NSCache()
    
    lazy var basicSession : URLSession = {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        return session
    }()
    
    func session(with config : Configuration) -> URLSession {
        switch config {
        default:
            return basicSession
        }
    }
    
    var environment : Environment = Environment.environment(with: .development)
}
