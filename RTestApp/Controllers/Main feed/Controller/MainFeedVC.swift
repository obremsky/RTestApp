//
//  MainFeedVC.swift
//  RTestApp
//
//  Created by Viacheslav Obremskyi on 04.11.2020.
//

import UIKit

class MainFeedVC: UITableViewController {
    
    private var items = [RedditFeedItem]()
    
    var feedService: RedditFeedService?
    
    private var isLoading: Bool = false
    private var canLoadMore: Bool = true
    private var pageSize: Int = 50
    private var visibleCellsCount = 0
    
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
        refresh(fromStart: true)
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
        refresh(fromStart: true)
    }
    
    private func refresh(fromStart : Bool) {
        if fromStart {
            canLoadMore = true
            feedService?.cancel()
        } else {
            if isLoading { return }
        }
        
        isLoading = true
        if !activityView.isAnimating && fromStart { activityView.startAnimating() }
        
        feedService = RedditFeedService (count: pageSize, before: items.last ,completion: {[weak self] (result) in
            
            guard let self = self else { return }
            if self.activityView.isAnimating { self.activityView.stopAnimating() }
            
            switch result {
            case .success(let items):
                if fromStart {
                    self.items = items
                    self.tableView.reloadData()
                    self.visibleCellsCount = self.tableView.indexPathsForVisibleRows?.count ?? 0
                    
                } else {
                    guard items.count > 0 else {
                        self.isLoading = false
                        self.canLoadMore = false
                        return
                    }
                    
                    let startRow = self.items.count
                    
                    var indexPathes = [IndexPath]()
                    for i in startRow..<items.count+startRow {
                        indexPathes.append(IndexPath(item: i, section: 0))
                    }
                    
                    self.items.append(contentsOf: items)
                    if items.count < self.pageSize {
                        self.canLoadMore = false
                    }
                    
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: indexPathes, with: .bottom)
                    self.tableView.endUpdates()
                }
            case .failure(let error):
                print(error)
            }
            
            self.isLoading = false
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard !isLoading && canLoadMore else { return }
        if indexPath.row == items.count - visibleCellsCount * 2 {
            refresh(fromStart: false)
        }
    }
}
