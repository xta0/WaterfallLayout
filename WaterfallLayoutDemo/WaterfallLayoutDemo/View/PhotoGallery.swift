//
//  PhotoGallary.swift
//  WaterfallLayoutDemo
//
//  Created by Tao Xu on 1/24/25.
//

import UIKit

@MainActor
protocol PhotoGalleryDelegate: AnyObject {
    func presentAlert(title: String, message: String)
}


@MainActor
final class PhotoGallary: UIView {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRectZero
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    lazy var scrollView: UIScrollView =  {
        let scrollView = UIScrollView()
        scrollView.frame = self.bounds
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
        scrollView.delegate = self
        scrollView.backgroundColor = .black
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    weak var delegate: PhotoGalleryDelegate?
    
    private var currentScale: CGFloat = 1.0
    private var isZooming: Bool = false
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        self.backgroundColor = .black
        
        self.addSubview(self.scrollView)
        
        // support double tap
        let doubleTaps = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapped(_ :)))
        doubleTaps.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTaps)
        
        // support pinch
//        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
//        imageView.addGestureRecognizer(pinchGesture)
        
        self.scrollView.addSubview(imageView)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(close))
        singleTap.numberOfTapsRequired = 1
        singleTap.require(toFail: doubleTaps)
        self.scrollView.addGestureRecognizer(singleTap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let image = self.imageView.image else {
            return
        }
        let imgW = image.size.width
        let imgH = image.size.height
        
        let w = frame.size.width
        let h = w * imgH / imgW
        let x = (frame.width - w) / 2
        let y = (frame.size.height - h) / 2
        self.imageView.frame = CGRectMake(x, y, w, h)
        
        // update the scrollview's contente size
        self.scrollView.contentSize = CGSize(width: w, height: h)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func handleDoubleTapped(_ gesture: UITapGestureRecognizer) {
        if isZooming {
            scrollView.setZoomScale(1.0, animated: true)
            isZooming = false
            return
        }
        isZooming = true
        // zoom by 50%
        let pointInView = gesture.location(in: imageView)
        
        // Calculate the new zoom scale: 1.5 (i.e., 50% bigger)
        var newZoomScale = scrollView.zoomScale * 1.5
        newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)  // don’t exceed maxZoom
        
        // The size of the scrollView (visible area):
        let scrollViewSize = scrollView.bounds.size
        
        // The size of the region to zoom to:
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (width / 2.0)
        let y = pointInView.y - (height / 2.0)
        
        let zoomRect = CGRect(x: x, y: y, width: width, height: height)
        scrollView.zoom(to: zoomRect, animated: true)
    }
    
    @objc
    func handlePinch(_ sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult else { return }
        guard let imageView = sender.view else {
            return
        }
        imageView.transform = scale
        sender.scale = 1
        
        if sender.state == .ended && imageView.transform.a < 1.0 {
            UIView.animate(withDuration: 0.2) {
                sender.view?.transform = CGAffineTransform.identity
            }
        }
    }
    
    @objc
    func close(_ sender: UITapGestureRecognizer) {
        self.removeFromSuperview()
    }
    
    func showImage(_ full: String) {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = self.center
        spinner.startAnimating()
        self.addSubview(spinner)
        Task { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let (_, image) = await ImageDownloader.shared.fetchImage(URL(string: full)!, identifier: "")
            spinner.removeFromSuperview()
            guard let fullImage = image else {
                strongSelf.delegate?.presentAlert(title: "Error", message: "failed to download the image")
                return
            }
            strongSelf.imageView.image = fullImage
            strongSelf.imageView.isUserInteractionEnabled = true
            strongSelf.setNeedsLayout()
        }
    }
}


extension PhotoGallary: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageView()
    }
    
    private func centerImageView() {
        // If the content size is smaller than the scroll view’s bounds,
        // calculate offsets so the imageView stays in the center.
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        
        // Adjust the imageView’s center accordingly
        imageView.center = CGPoint(
            x: scrollView.contentSize.width * 0.5 + offsetX,
            y: scrollView.contentSize.height * 0.5 + offsetY
        )
    }
}
