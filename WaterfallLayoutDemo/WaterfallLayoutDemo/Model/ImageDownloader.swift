//
//  ImageDownloader.swift
//  WaterfallLayoutDemo
//
//  Created by Tao Xu on 1/14/25.
//

import Foundation
import UIKit


final class ImageDownloader {
    nonisolated(unsafe) static let shared = ImageDownloader()
    
    private let memCahe: NSCache<NSString, UIImage> = NSCache()
    private let imageCache = ImageCache()
    
    func fetchImageFromMemoryCache(_ url: String) -> UIImage? {
        return memCahe.object(forKey: url as NSString)
    }
    
    func fetchImage(_ url: URL, identifier: String) async -> (String, UIImage?) {
        if let image = self.fetchImageFromMemoryCache(url.absoluteString) {
            return (identifier, image)
        }
        if let image = await imageCache.fetchImage(url) {
            self.memCahe.setObject(image, forKey: url.absoluteString as NSString)
            return (identifier, image)
        }
        return (identifier, nil)
    }
    
//    func downloadImage(_ url: URL, identifier: String, completion: @escaping (String, UIImage?)->Void) {
//        DispatchQueue.global().async {
//            if let data = try? Data(contentsOf: url) {
//                if let image = UIImage(data: data) {
//                    self.memCahe.setObject(image, forKey: url.absoluteString as NSString)
//                    completion(identifier, image)
//                } else {
//                    completion(identifier, nil)
//                }
//            } else {
//                completion(identifier, nil)
//            }
//        }
//    }
}
