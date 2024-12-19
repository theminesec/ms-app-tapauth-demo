//
//  NetworkClient.swift
//  TapToAuth Demo
//
//  Created by Admin on 19/12/2024.
//

import Foundation

class NetworkClient {
    static let shared = NetworkClient()
    
    private init() {}
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    private func request<T: Decodable>(
        urlString: String,
        httpMethod: HTTPMethod,
        body: Data? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func get<T: Decodable>(
        urlString: String,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        request(
            urlString: urlString,
            httpMethod: .get,
            body: nil,
            responseType: responseType,
            completion: completion
        )
    }
    
    func post<T: Codable, U: Decodable>(
        urlString: String,
        body: T,
        responseType: U.Type,
        completion: @escaping (Result<U, Error>) -> Void
    ) {
        do {
            let jsonData = try JSONEncoder().encode(body)
            request(
                urlString: urlString,
                httpMethod: .post,
                body: jsonData,
                responseType: responseType,
                completion: completion
            )
        } catch {
            completion(.failure(NetworkError.encodingFailed))
        }
    }
    
    enum NetworkError: Error {
        case invalidURL
        case noData
        case encodingFailed
    }
}



/*
 NetworkClient.shared.get(
     urlString: "https://jsonplaceholder.typicode.com/todos/1",
     responseType: Todo.self
 ) { result in
     switch result {
     case .success(let todo):
         print("Fetched Todo: \(todo)")
     case .failure(let error):
         print("Error: \(error.localizedDescription)")
     }
 }
 
 let newPost = PostRequest(title: "foo", body: "bar", userId: 1)

 NetworkClient.shared.post(
     urlString: "https://jsonplaceholder.typicode.com/posts",
     body: newPost,
     responseType: PostResponse.self
 ) { result in
     switch result {
     case .success(let postResponse):
         print("Created Post: \(postResponse)")
     case .failure(let error):
         print("Error: \(error.localizedDescription)")
     }
 }
 */
