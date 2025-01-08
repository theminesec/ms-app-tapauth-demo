//
//  NetworkLogger.swift
//  TapToAuth Demo
//
//  Created by Admin on 27/12/2024.
//

import Foundation

func logRequest(url: URL, method: String, body: Data?) {
    print("\n--- Request ---")
    print("URL: \(url)")
    print("Method: \(method)")
    if let apiKey = retrieveUser()?.token {
        print("Headers: [x-api-key: \(apiKey)]")
    } else {
        print("Headers: [x-api-key: nil]")
    }
    if let body = body, let jsonString = String(data: body, encoding: .utf8) {
        print("Body: \(jsonString)")
    } else {
        print("Body: nil")
    }
    print("--- End Request ---\n")
}

func logResponse(url: URL, response: URLResponse?, data: Data) {
    print("\n--- Response ---")
    print("URL: \(url)")
    if let httpResponse = response as? HTTPURLResponse {
        print("Status Code: \(httpResponse.statusCode)")
    }
    if let jsonString = String(data: data, encoding: .utf8) {
        print("Body: \(jsonString)")
    } else {
        print("Body: Unable to parse response data.")
    }
    print("--- End Response ---\n")
}

func logError(_ message: String) {
    print("\n--- Error ---")
    print(message)
    print("--- End Error ---\n")
}
