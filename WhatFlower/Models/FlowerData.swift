//
//  FlowerData.swift
//  WhatFlower
//
//  Created by Omar Ashraf on 22/02/2024.
//

import Foundation

struct FlowerData: Codable {
    let query: Query
}

struct Query: Codable {
    let pages: [Page]
}

struct Page: Codable {
    let extract: String
    let thumbnail: Thumbnail
}

struct Thumbnail: Codable {
    let source: String
}

