//
//  Network.swift
//  WaterfallLayoutDemo
//
//  Created by Tao Xu on 1/13/25.
//

import Foundation

enum Unsplash {
    static let photos = "https://api.unsplash.com/collections/317099/photos"
    static let search = "https://api.unsplash.com/search/photos"
    
}

extension Endpoint where T == [Photo] {
    static func fetchPhotos(_ pageIndex: Int, count: Int) async -> [Photo]? {
        let e = Endpoint(
            url: URL(string: Unsplash.photos)!,
            params: [
                "page": "\(pageIndex)",
                "per_page": "\(count)"
            ]) { (data, response) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return nil
                }
                guard let data else {
                    return nil
                }
                guard httpResponse.statusCode == 200 else {
                    return nil
                }
                do {
                    guard let rawPhotos = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                        return nil
                    }
                    var photos: [Photo] = []
                    for rawPhoto in rawPhotos {
                        if let user = rawPhoto["user"] as? [String: Any],
                           let title = user["username"] as? String,
                           let identifier = rawPhoto["id"] as? String,
                           let urls = rawPhoto["urls"] as? [String: Any],
                           let width = rawPhoto["width"] as? Int,
                           let height = rawPhoto["height"] as? Int,
                           let thumbImageURL = urls["thumb"] as? String,
                           let fullImageURL = urls["full"] as? String {
                            photos.append(Photo(identifier: identifier, title: title, thumb_url: thumbImageURL, full_url: fullImageURL, width: width, height: height))
                        }
                    }
                    return photos
                } catch {
                    return nil
                }
            }
        return await URLSession.shared.load(e)
    }
    
    static func searchPhotos(_ query: String, pageIndex: Int, count: Int) async -> [Photo]? {
        let e = Endpoint(url: URL(string: Unsplash.search)!, params: [
            "content_filter": "low",
            "page": "\(pageIndex)",
            "per_page": "\(count)",
            "query": query]) { (data, response) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return nil
                }
                guard let data else {
                    return nil
                }
                guard httpResponse.statusCode == 200 else {
                    return nil
                }
                do {
                    guard let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        return nil
                    }
                    guard let rawPhotos = result["results"] as? [[String: Any]] else {
                        return nil
                    }
                    var photos: [Photo] = []
                    for rawPhoto in rawPhotos {
                        if let user = rawPhoto["user"] as? [String: Any],
                           let title = user["username"] as? String,
                           let identifier = rawPhoto["id"] as? String,
                           let urls = rawPhoto["urls"] as? [String: Any],
                           let width = rawPhoto["width"] as? Int,
                           let height = rawPhoto["height"] as? Int,
                           let thumbImageURL = urls["thumb"] as? String,
                           let fullImageURL = urls["full"] as? String {
                            photos.append(Photo(identifier: identifier, title: title, thumb_url: thumbImageURL, full_url: fullImageURL, width: width, height: height))
                        }
                    }
                    return photos
                } catch {
                    return nil
                }
            }
        return await URLSession.shared.load(e)
    }
}
