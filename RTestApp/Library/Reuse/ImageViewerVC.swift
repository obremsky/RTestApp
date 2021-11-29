//
//  ImageViewerVC.swift
//  RTestApp
//
//  Created by Viacheslav Obremskyi on 04.11.2020.
//

import UIKit
import Photos

class ImageViewerVC: UIViewController {
    
    var imagePath : String?
    var thumbService : DownloadImageService?
    
    private lazy var activityView: UIActivityIndicatorView = {
        let actity =  UIActivityIndicatorView(style: .large)
        self.view.addSubview(actity)
        return actity
    }()

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressReconnizer = UILongPressGestureRecognizer(target: self, action: #selector(onSaveImage(_:)))
        imageView.addGestureRecognizer(longPressReconnizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadImage()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        activityView.center = view.center
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        thumbService?.cancel()
        thumbService = nil
        activityView.stopAnimating()
    }
    
    private func loadImage() {
        guard let path = imagePath else { return }
        
        activityView.startAnimating()
        let service = DownloadImageService(url: path) {[weak self] (result) in
            self?.activityView.stopAnimating()
            switch result {
            case .success(let image):
                self?.imageView.image = image
                self?.imageView.isUserInteractionEnabled = true
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: "Something went wrong :(. Error: \(error)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
        service.start()
        thumbService = service
    }
    
    @objc func onSaveImage(_ sender : UILongPressGestureRecognizer) {
        let alert = UIAlertController(title: "Save image yo your gallery?", message: nil, preferredStyle: .actionSheet)
        
        if  UIDevice.current.userInterfaceIdiom == .pad {
            alert.popoverPresentationController?.permittedArrowDirections = .down
            alert.popoverPresentationController?.sourceRect = CGRect(x: view.frame.midX - 2, y: view.frame.maxY, width: 4, height: 4)
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: {[weak self] (_) in
            self?.save()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func save() {
        guard let image = imageView.image else { return }
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            default:
                break
            }
        }
    }
}
