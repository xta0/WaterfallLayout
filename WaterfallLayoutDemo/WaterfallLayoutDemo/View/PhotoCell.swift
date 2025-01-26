//
//  PhotoCell.swift
//  WaterfallLayoutDemo
//
//  Created by Tao Xu on 1/14/25.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    static let reuseIdentifier: String = "\(PhotoCell.self)"
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRectZero
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRectZero
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private(set) var photo: Photo?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupviews()
    }
    
    func setupviews() {
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 1
        contentView.backgroundColor = .black
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
    }
    //            // download the image
    //            ImageDownloader.shared.downloadImage(URL(string: photo.url)!, identifier: photo.identifier) { [weak self] (identifier, image) in
    //                guard let strongSelf = self else {
    //                    return
    //                }
    //                guard let image else {
    //                    return
    //                }
    //                if identifier != strongSelf.photo?.identifier {
    //                    return
    //                }
    //                DispatchQueue.main.async {
    //                    strongSelf.imageView.image = image
    //                }
    //            }

    func setPhoto(_ photo: Photo) {
        self.photo = photo
        // read image from a memory cache
        if let image = ImageDownloader.shared.fetchImageFromMemoryCache(photo.thumb_url) {
            imageView.image = image
        } else {
            Task { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                let (id, image) = await ImageDownloader.shared.fetchImage(URL(string: photo.thumb_url)!, identifier: photo.identifier)
                if id != strongSelf.photo?.identifier {
                    return
                }
                Task { @MainActor in
                    strongSelf.imageView.image = image
                }
            }

        }
        titleLabel.text = photo.title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        titleLabel.frame = CGRect(x: 0, y: bounds.height - 20, width: bounds.width, height: 20)
    }
}
