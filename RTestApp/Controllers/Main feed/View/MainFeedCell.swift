//
//  MainFeedCell.swift
//  RTestApp
//
//  Created by Viacheslav Obremskyi on 04.11.2020.
//

import UIKit

protocol MainFeedItemProtocol {
    var titleValue : String? { get }
    var commentsValue : String? { get }
    var authorValue : String? { get }
    var thumbnailValue : String? { get }
    var fullImageValue : String? { get }
}

class MainFeedCell: UITableViewCell {
    
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    var item : MainFeedItemProtocol!
    var thumbService : DownloadImageService?
    var imageTapBlock : ((MainFeedItemProtocol)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnImage(_:)))
        thumbImageView.addGestureRecognizer(gestureRecognizer)
    }

    func configure(with item : MainFeedItemProtocol, imageTapBlock: ((MainFeedItemProtocol)->())? = nil) {
        self.item = item
        self.imageTapBlock = imageTapBlock
        
        titleLabel.text = item.titleValue
        authorLabel.text = item.authorValue
        commentsLabel.text = item.commentsValue

        if let url = item.thumbnailValue {
            let service = DownloadImageService(url: url) {[weak self] (result) in
                switch result {
                case .success(let image):
                    self?.thumbImageView.image = image
                    self?.thumbImageView.isUserInteractionEnabled = true
                default:
                    break
                }
            }
            
            service.start()
            thumbService = service
        }
    }
    
    @objc func didTapOnImage(_ sender : UITapGestureRecognizer) {
        imageTapBlock?(item)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbImageView.isUserInteractionEnabled = false
        thumbImageView.image = nil
        thumbService?.cancel()
        thumbService = nil
    }
}
