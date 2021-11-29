//
//  Environment.swift
//  RTestApp
//
//  Created by Viacheslav Obremskyi on 03.11.2020.
//

import Foundation

enum EnvironmentType {
    case development
}

@objc class Environment : NSObject{
    let apiUrl : String
    
    init(apiUrl: String, port: String? = nil){
        self.apiUrl = apiUrl
    }
    
    class func environment(with type : EnvironmentType) -> Environment{
        switch type {
        case .development:
            return DevelopmentEnvironment()
        }
    }
}

class DevelopmentEnvironment : Environment{
    init() {
        let apiUrl = "https://www.reddit.com/"
        super.init(apiUrl: apiUrl)
    }
}


