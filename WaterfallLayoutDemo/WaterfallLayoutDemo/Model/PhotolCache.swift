//
//  ModelCache.swift
//  WaterfallLayoutDemo
//
//  Created by Tao Xu on 1/24/25.
//

import Foundation

actor PhotoCache {
    // A directory path to store image files on disk
    private lazy var diskCacheDirectory: URL? = {
        //  use your app's caches directory
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        guard let cacheDirectory = paths.first else { return nil }
        
        // Create a subdirectory for images if you want to separate them
        let photoCacheDir = cacheDirectory.appendingPathComponent("PhotoCache")
        if !FileManager.default.fileExists(atPath: photoCacheDir.path) {
            do {
                try FileManager.default.createDirectory(at: photoCacheDir,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                print("Error creating images directory:", error.localizedDescription)
                return nil
            }
        }
        return photoCacheDir
    }()
    
    private var jsonEncoder = JSONEncoder()
    private var jsonDecoder = JSONDecoder()
    
    func savePhotos(_ photos:[Photo]) async -> Bool {
        guard let data =  try? jsonEncoder.encode(photos) else {
            return false
        }
        guard let diskCacheDirectory = diskCacheDirectory else {
            return false
        }
        // write data to the disk
        let filePath = diskCacheDirectory.appendingPathComponent("photos.json")
        do {
            try data.write(to: filePath)
            print("saving data to disk successfully!")
            return true
        } catch let error {
            print("error: \(error.localizedDescription)")
        }
        return false
    }
    
    func loadPhotos() async -> [Photo]? {
        guard let diskCacheDirectory = diskCacheDirectory else {
            return nil
        }
        let filePath = diskCacheDirectory.appendingPathComponent("photos.json")
        guard let data = try? Data(contentsOf: filePath) else {
            return nil
        }
        guard let photos = try? jsonDecoder.decode([Photo].self, from: data) else {
            return nil
        }
        return photos
    }
    
}
