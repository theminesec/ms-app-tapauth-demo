//
//  NetworkClient.swift
//  TapToAuth Demo
//
//  Created by Admin on 19/12/2024.
//

import Foundation
import FirebaseDatabase
import Foundation

class NetworkClient {
    static let shared = NetworkClient()
    
    private init() {}
    
    private let baseURL = Constants.APIEndpoints.baseURL
    private let logger = NetworkLogger.shared // Initialize the logger

    enum API {
        case login
        case fcmTokenUpload
        case orders(cardNo: String)
        case reject(actionId: String)
        case confirm(actionId: String)
        
        var path: String {
            switch self {
            case .login:
                return Constants.APIEndpoints.login
            case .fcmTokenUpload:
                return Constants.APIEndpoints.fcmTokenUpload
            case .orders(let cardNo):
                return String(format: Constants.APIEndpoints.orders, cardNo)
            case .reject(let actionId):
                return String(format: Constants.APIEndpoints.reject, actionId)
            case .confirm(let actionId):
                return String(format: Constants.APIEndpoints.confirm, actionId)
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
            // Generate a dynamic Firebase node ID
            let firebaseNodeID = logger.generateFirebaseNodeID()
            
            // Log the error with the node ID
            logger.logError(message: "Invalid URL: \(baseURL + endpoint.path)", firebaseNodeID: firebaseNodeID)
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
        
        // Generate a dynamic Firebase node ID
        let firebaseNodeID = logger.generateFirebaseNodeID()
        
        // Log the request with the node ID
        logger.logRequest(request: request, firebaseNodeID: firebaseNodeID)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // Log the error with the node ID
                self.logger.logError(message: "Request failed: \(error.localizedDescription)", firebaseNodeID: firebaseNodeID)
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    // Mock response for testing
                    if let mockData = mockOrdersResponse() {
                        self.logger.logResponse(response: httpResponse, data: mockData, firebaseNodeID: firebaseNodeID)
                        do {
                            let decodedData = try JSONDecoder().decode(T.self, from: mockData)
                            completion(.success(decodedData))
                        } catch {
                            // Log the error with the node ID
                            self.logger.logError(message: "Decoding mock data failed: \(error.localizedDescription)", firebaseNodeID: firebaseNodeID)
                            completion(.failure(error))
                        }
                        return
                    }
                }
            }
            
            guard let data = data else {
                // Log the error with the node ID
                self.logger.logError(message: "No data received for \(url)", firebaseNodeID: firebaseNodeID)
                completion(.failure(NetworkError.noData))
                return
            }
            
            // Log the response with the node ID
            if let httpResponse = response as? HTTPURLResponse {
                self.logger.logResponse(response: httpResponse, data: data, firebaseNodeID: firebaseNodeID)
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                // Log the error with the node ID
                self.logger.logError(message: "Decoding failed for \(url): \(error.localizedDescription)", firebaseNodeID: firebaseNodeID)
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
            completion(.failure(NetworkError.encodingFailed))
        }
    }
    
    enum NetworkError: Error {
        case invalidURL
        case noData
        case encodingFailed
    }
}


// MARK: - Mock Data
private func mockOrdersResponse() -> Data? {
    let mockJSON = """
    {
      "code": 0,
      "message": "success",
      "body": {
        "list": [
          {
            "actionId": "1000000000",
            "orderId": "985585623352366",
            "description": "new order with 100inches flat screen",
            "amount": "128.35",
            "fullCardNo": "6217445869663658",
            "created": 1633660800,
            "expired": 1633662600,
            "status": "PENDING"
          },
          {
            "actionId": "1000000001",
            "orderId": "985585623352367",
            "description": "new order with 100inches flat screen",
            "amount": "138.35",
            "fullCardNo": "6217445869663658",
            "created": 1633660800,
            "expired": 1633662600,
            "status": "CONFIRMED"
          },
          {
            "actionId": "1000000002",
            "orderId": "985585623352368",
            "description": "new order with 100inches flat screen",
            "amount": "148.35",
            "fullCardNo": "6217445869663658",
            "created": 1633660800,
            "expired": 1633662600,
            "status": "REJECTED"
          }
        ],
        "total": 3
      }
    }
    """
    return mockJSON.data(using: .utf8)
}
