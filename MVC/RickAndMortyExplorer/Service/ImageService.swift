//
//  ImageLoader.swift
//  RickAndMortyExplorer
//
//  Created by Toly on 29.09.2025.
//

import UIKit

final class ImageService {
    private let cache = URLCache.shared
    private let memoryCache = NSCache<NSString, UIImage>()
    private let session = URLSession.shared

    public init() {}

    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        // Проверяем кэш в памяти
        if let cachedImage = memoryCache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }

        // Проверяем кеш
        let request = URLRequest(url: url)
        if let cachedResponse = cache.cachedResponse(for: request), let image = UIImage(data: cachedResponse.data) {
            memoryCache.setObject(image, forKey: urlString as NSString)
            completion(image)
            return
        }

        // Загружаем с сети
        session.dataTask(with: request) { [weak self] data, response, error in
            guard
                let self = self,
                let data = data,
                let response = response,
                let image = UIImage(data: data),
                error == nil
            else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            // Сохраняем и в память, и в URLCache
            self.memoryCache.setObject(image, forKey: urlString as NSString)
            let cachedData = CachedURLResponse(response: response, data: data)
            self.cache.storeCachedResponse(cachedData, for: request)

            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
