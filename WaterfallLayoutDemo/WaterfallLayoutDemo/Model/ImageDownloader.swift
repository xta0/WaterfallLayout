//
//  ImageDownloader.swift
//  WaterfallLayoutDemo
//
//  Created by Tao Xu on 1/14/25.
//

import Foundation
import UIKit

class ImageDownloader {
    static let shared = ImageDownloader()
    private let queue: DispatchQueue = DispatchQueue(label: "com.waterfalllayout.imageDownloader")
    private let memCahe: NSCache<NSString, UIImage> = NSCache()
    
    func fetchImageFromCache(_ url: String) -> UIImage? {
        return memCahe.object(forKey: url as NSString)
    }
    func downloadImage(_ url: URL, identifier: String, completion: @escaping (String, UIImage?)->Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    self.memCahe.setObject(image, forKey: url.absoluteString as NSString)
                    completion(identifier, image)
                } else {
                    completion(identifier, nil)
                }
            } else {
                completion(identifier, nil)
            }
        }
    }
}
