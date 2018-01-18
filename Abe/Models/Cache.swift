//
//  Cache.swift
//  Abe
//
//  Created by Robert Rozenvasser on 1/17/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation

struct FileStorage {
    let baseURL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    subscript(key: String) -> Data? {
        get {
            let url = baseURL.appendingPathComponent(key)
            return try? Data(contentsOf: url)
        }
        set {
            let url = baseURL.appendingPathComponent(key)
            _ = try? newValue?.write(to: url)
        }
    }
}

//final class Cache {
//
//    static let shared = Cache()
//    private var storage = FileStorage()
//
//    private init () { }
//
//    func load<T>(_ resource: Resource<T>, cacheKey: String) -> T? {
//        let data = storage[cacheKey]
//        return data.flatMap(resource.parse)
//    }
//
//    func saveData<T>(_ data: Data, for resource: Resource<T>, cacheKey: String) {
//        storage[cacheKey] = data
//    }
//
//}

