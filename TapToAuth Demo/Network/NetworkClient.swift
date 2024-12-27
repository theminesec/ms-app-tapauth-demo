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
    
    private let baseURL = Constants.APIEndpoints.baseURL
    
    enum API {
        case login
        case fcmTokenUpload

        var path: String {
            switch self {
            case .login:
                return Constants.APIEndpoints.login
            case .fcmTokenUpload:
                return Constants.APIEndpoints.fcmTokenUpload
            }
        }
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    private func request<T: Decodable>(
        endpoint: API,
        httpMethod: HTTPMethod,
        body: Data? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint.path) else {
            logError("Invalid URL: \(baseURL + endpoint.path)")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        if let apiKey = retrieveUser()?.token {
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        logRequest(url: url, method: httpMethod.rawValue, body: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                logError("Request failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                logError("No data received for \(url)")
                completion(.failure(NetworkError.noData))
                return
            }
            
            logResponse(url: url, response: response, data: data)
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                logError("Decoding failed for \(url): \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func get<T: Decodable>(
        endpoint: API,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        request(
            endpoint: endpoint,
            httpMethod: .get,
            body: nil,
            responseType: responseType,
            completion: completion
        )
    }
    
    func post<T: Codable, U: Decodable>(
        endpoint: API,
        body: T,
        responseType: U.Type,
        completion: @escaping (Result<U, Error>) -> Void
    ) {
        do {
            let jsonData = try JSONEncoder().encode(body)
            request(
                endpoint: endpoint,
                httpMethod: .post,
                body: jsonData,
                responseType: responseType,
                completion: completion
            )
        } catch {
            logError("Encoding failed for \(endpoint.path): \(error.localizedDescription)")
            completion(.failure(NetworkError.encodingFailed))
        }
    }
    
    enum NetworkError: Error {
        case invalidURL
        case noData
        case encodingFailed
    }
}
