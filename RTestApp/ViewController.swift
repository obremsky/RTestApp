//
//  ViewController.swift
//  RTestApp
//
//  Created by Viacheslav Obremskyi on 03.11.2020.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RedditFeedService (completion: { (result) in
            switch result {
            case .success(let items):
                items.forEach { (item) in
                    print(item.title)
                }
            case .failure(let error):
                print(error)
            }
        }).start()
    }
}

