//
//  Endpoint.swift
//  WaterfallLayoutDemo
//
//  Created by Tao Xu on 1/13/25.
//

import Foundation

// TODO: Define a network error enum

struct Endpoint<T> {
    let url: URL
    let params: [String: String]
    var parse: @Sendable (Data?, URLResponse?) -> T?
}

extension Endpoint {
    var request: URLRequest? {
        var requestURL: URL?
        if params.isEmpty {
            requestURL = url
        } else {
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: true)
            var queryItems = comps?.queryItems ?? []
            queryItems.append(contentsOf: params.sorted(by: <).map { URLQueryItem(name: $0.0, value: $0.1) })
            comps?.queryItems = queryItems
            requestURL = comps?.url
        }
        guard let requestURL else { return nil }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Client-ID pGlGscS5JMBiki2Z47AKZstC0_q2rEoJZsbqdvfZx00", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10
        return request
    }
}

extension URLSession {
    func load<T>(_ e: Endpoint<T>) async -> T? {
        guard let request = e.request else {
            return nil
        }
        print(request)
        if let (data, response) = try? await self.data(for: request) {
            return e.parse(data, response)
        }
        return nil
    }
}

