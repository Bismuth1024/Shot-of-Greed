//
//  File Helpers.swift
//  Fwaeh
//
//  Created by Manith Kha on 8/1/2025.
//

import Foundation

func documentsURL() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}

func sessionLogsURL() -> URL {
    return documentsURL().appendingPathComponent("logs/")
}

import Foundation

func save<T: Codable>(_ object: T, to fileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
    let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
    return save(object, to: fileURL, completion: completion)
}

func load<T: Codable>(_ type: T.Type, from fileName: String, completion: @escaping (Result<T, Error>) -> Void) {
    let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
    return load(T.self, from: fileURL, completion: completion)
}

func save<T: Codable>(_ object: T, to fileURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
    DispatchQueue.global(qos: .background).async {
        do {
            let data = try JSONEncoder().encode(object)
            try data.write(to: fileURL)
            DispatchQueue.main.async {
                completion(.success((fileURL)))
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
}

func load<T: Codable>(_ type: T.Type, from fileURL: URL, completion: @escaping (Result<T, Error>) -> Void) {
    DispatchQueue.global(qos: .background).async {
        do {
            let data = try Data(contentsOf: fileURL)
            let object = try JSONDecoder().decode(type, from: data)
            DispatchQueue.main.async {
                completion(.success(object))
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
}

func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}
