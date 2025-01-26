//
//  Page.swift
//  WaterfallLayoutDemo
//
//  Created by Tao Xu on 1/13/25.
//

    
struct Photo: Encodable, Decodable {
    let identifier: String
    let title: String
    let thumb_url: String
    let full_url: String
    let width: Int
    let height: Int
}
