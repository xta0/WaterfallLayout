//
//  UnsplashModel.swift
//  WaterfallLayoutDemo
//
//  Created by Tao Xu on 1/14/25.
//
import Foundation

@MainActor
final class UnsplashModel {
    private(set) var currentPage: Int = 1
    private(set) var pageCount: Int = 30
    private(set) var photos:[Photo] = []
    
    private let photoCache = PhotoCache()
    
    @discardableResult
    func fetchPhotos() async -> [Photo]? {
        guard let photos = await Endpoint.fetchPhotos(self.currentPage, count: self.pageCount) else {
            // this wont block the main thread
            if let cachedPhotos = await self._loadCachedPhotos() {
                print("load cached photos succeeded!")
                self.photos += cachedPhotos
                return cachedPhotos
            }
            print("load cached photos failed!")
            return nil
        }
        self.photos += photos
        self.currentPage += 1
        // this will not block the main thread
        // because it runs on its own actor
        await self ._savePhotos(photos)
        return photos
    }
    
    @discardableResult
    func fetchPhotos(_ keyword: String) async -> [Photo]? {
        guard  let photos = await Endpoint.searchPhotos(keyword, pageIndex: self.currentPage, count: self.pageCount) else {
            return nil
        }
        self.photos += photos
        self.currentPage += 1

        return photos
    }
        
    func reset() {
        self.currentPage = 1
        self.photos.removeAll()
    }
    
    func _savePhotos(_ photos: [Photo]) async {
        if await self.photoCache.savePhotos(photos) {
            print("saving photos succeeded!")
        } else {
            print("saving photos failed!")
        }
    }
    
    func _loadCachedPhotos() async -> [Photo]? {
        return await photoCache.loadPhotos()
    }
}
