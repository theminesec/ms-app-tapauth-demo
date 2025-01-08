//
//  FirebaseNetworkLogger.swift
//  TapToAuth Demo
//
//  Created by Admin on 08/01/2025.
//
import FirebaseDatabase

class NetworkLogger {
    static let shared = NetworkLogger()
    private let database = Database.database().reference()
    private let deviceID: String
    
    private init() {
        if let id = UserDefaults.standard.string(forKey: "device_id") {
            deviceID = id
        } else {
            deviceID = UUID().uuidString
            UserDefaults.standard.set(deviceID, forKey: "device_id")
        }
    }
    
    // Generate a Firebase dynamic node ID
    func generateFirebaseNodeID() -> String {
        return database.child("logs").child(deviceID).childByAutoId().key ?? UUID().uuidString
    }
    
    // Log the request
    func logRequest(request: URLRequest, firebaseNodeID: String) {
        guard let url = request.url?.absoluteString else { return }
        var log: [String: Any] = [
            "url": url,
            "method": request.httpMethod ?? "UNKNOWN",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let headers = request.allHTTPHeaderFields {
            log["headers"] = headers
        }
        if let body = request.httpBody {
            log["body"] = String(data: body, encoding: .utf8) ?? "BINARY_DATA"
        }
        
        print("Request logged: \(log)")
        saveToFirebase(logType: "request", log: log, firebaseNodeID: firebaseNodeID)
    }
    
    // Log the response
    func logResponse(response: HTTPURLResponse, data: Data?, firebaseNodeID: String) {
        var log: [String: Any] = [
            "status_code": response.statusCode,
            "url": response.url?.absoluteString ?? "UNKNOWN",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let headers = response.allHeaderFields as? [String: Any] {
            log["headers"] = headers
        }
        if let responseData = data {
            log["body"] = String(data: responseData, encoding: .utf8) ?? "BINARY_DATA"
        }
        
        print("Response logged: \(log)")
        saveToFirebase(logType: "response", log: log, firebaseNodeID: firebaseNodeID)
    }
    
    // Log errors
    func logError(message: String, firebaseNodeID: String) {
        let log: [String: Any] = [
            "error": message,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        print("Error logged: \(log)")
        saveToFirebase(logType: "error", log: log, firebaseNodeID: firebaseNodeID)
    }
    
    // Save logs to Firebase under the dynamic node ID
    private func saveToFirebase(logType: String, log: [String: Any], firebaseNodeID: String) {
        database.child("logs").child(deviceID).child(firebaseNodeID).child(logType).setValue(log)
    }
}
