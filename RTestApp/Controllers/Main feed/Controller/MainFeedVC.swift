//
//  MainFeedVC.swift
//  RTestApp
//
//  Created by Viacheslav Obremskyi on 04.11.2020.
//

import UIKit

class MainFeedVC: UITableViewController {
    
    private var items = [RedditFeedItem]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var feedService: RedditFeedService?
    
    private lazy var refreshControll: UIRefreshControl = {
        let result = UIRefreshControl()
        result.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return result
    }()
    
    private lazy var activityView: UIActivityIndicatorView = {
        let actity =  UIActivityIndicatorView(style: .large)
        self.view.addSubview(actity)
        return actity
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MainFeedCell", bundle: nil), forCellReuseIdentifier: "FeedItemCell")
        tableView.tableFooterView = UIView()
        tableView.addSubview(self.refreshControll)
        
        refresh()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        feedService?.cancel()
        activityView.stopAnimating()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.activityView.center = view.center
    }
    
    @objc private func refreshData() {
        refreshControll.endRefreshing()
        refresh()
    }
    
    private func refresh() {
        
        if !activityView.isAnimating  { activityView.startAnimating() }
        feedService?.cancel()
        feedService = RedditFeedService (completion: {[weak self] (result) in
            self?.activityView.stopAnimating()
            
            switch result {
            case .success(let items):
                self?.items = items
            case .failure(let error):
                print(error)
            }
        })
        feedService?.start()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedItemCell", for: indexPath)
        
        if let cell = cell as? MainFeedCell {
            cell.configure(with: items[indexPath.row]) {[weak self] (item) in
                if let path = item.fullImageValue {
                    let vc = ImageViewerVC(nibName: "ImageViewerVC", bundle: nil)
                    vc.imagePath = path
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
        return cell
    }
}
