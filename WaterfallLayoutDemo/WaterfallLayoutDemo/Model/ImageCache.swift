//
//  ImageCache.swift
//  WaterfallLayoutDemo
//
//  Created by Tao Xu on 1/20/25.
//

import Foundation
import UIKit

actor ImageCache {
    
    let diskCache = ImageDiskCache()

    func fetchImage(_ url: URL) async -> UIImage? {
        // fetch images from disck
        if let image = await diskCache.fetchImagesFromDisk(url) {
            print("fetched an image from the disk: \(url)")
            return image
        }
        // fetch images from HTTP
        if let image = self.downloadImage(url) {
            Task {
                // save the image to the disk
                // this runs on a different actor
                await diskCache.saveToDisk(image.pngData()!, urlString: url.absoluteString)
            }
            return image
        }
        
        return nil
    }
    
    func downloadImage(_ url: URL) -> UIImage? {
        if let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            return image
        }
        return nil
    }
}

