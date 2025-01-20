//
//  UnsplashModel.swift
//  WaterfallLayoutDemo
//
//  Created by Tao Xu on 1/14/25.
//

@MainActor
final class UnsplashModel {
    private(set) var currentPage: Int = 1
    private(set) var pageCount: Int = 30
    private(set) var photos:[Photo] = []
//    private(set) var loading: Bool = false
    
    @discardableResult
    func fetchPhotos() async -> [Photo]? {
        guard let photos = await Endpoint.fetchPhotos(self.currentPage, count: self.pageCount) else {
            return nil
        }
        self.photos += photos
        self.currentPage += 1
        // TODO: save the results to an cache
        return photos
    }
    
    @discardableResult
    func fetchPhotos(_ keyword: String) async -> [Photo]? {
        guard  let photos = await Endpoint.searchPhotos(keyword, pageIndex: self.currentPage, count: self.pageCount) else {
            return nil
        }
        self.photos += photos
        self.currentPage += 1
        // TODO: save the results to an cache
        return photos
    }
        
    func reset() {
        self.currentPage = 1
        self.photos.removeAll()
    }
}
