//
//  ImageDiskCache.swift
//  WaterfallLayoutDemo
//
//  Created by Tao Xu on 1/21/25.
//

import Foundation
import UIKit

actor ImageDiskCache {
    // A directory path to store image files on disk
    private lazy var diskCacheDirectory: URL? = {
        //  use your app's caches directory
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        guard let cacheDirectory = paths.first else { return nil }
        
        // Create a subdirectory for images if you want to separate them
        let imagesDir = cacheDirectory.appendingPathComponent("ImageCache")
        if !FileManager.default.fileExists(atPath: imagesDir.path) {
            do {
                try FileManager.default.createDirectory(at: imagesDir,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                print("Error creating images directory:", error.localizedDescription)
                return nil
            }
        }
        return imagesDir
    }()
    
    func saveToDisk(_ data: Data, urlString: String) async {
        guard let directory = diskCacheDirectory else { return }
        // Create unique filename, e.g. replace "/" with "_"
        let fileName = urlString.replacingOccurrences(of: "/", with: "_")
        let fileURL = directory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
        } catch {
            print("Error saving image to disk:", error.localizedDescription)
        }
    }
    
    func fetchImagesFromDisk(_ url: URL) async -> UIImage?  {
        guard let directory = diskCacheDirectory else { return nil }
         // The filename could be a hashed version of the urlString
        let urlString = url.absoluteString
         let fileName = urlString.replacingOccurrences(of: "/", with: "_")
         let fileURL = directory.appendingPathComponent(fileName)
         
         if FileManager.default.fileExists(atPath: fileURL.path),
            let data = try? Data(contentsOf: fileURL),
            let image = UIImage(data: data) {
             return image
         }
         return nil
    }
}
