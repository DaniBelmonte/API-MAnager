//
//  ApiManager.swift
//  News
//
//  Created by Dani on 18/2/23.
//

import Foundation

enum APIError: Error {
    case invalidResponse
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
//    TODO: not yet
//    case put = "PUT"
//    case delete = "DELETE"
}

protocol APIManagerProtocol {
    func callAPI<T: Codable>(endpoint: String, method: HTTPMethod, params: [String: Any]?, body: [String: Any]?) async throws -> T
}

class APIManager: APIManagerProtocol {

    private let baseUrl = BaseURL.newsV2.url

    func callAPI<T: Codable>(endpoint: String, method: HTTPMethod, params: [String: Any]?, body: [String: Any]? = nil) async throws -> T {

        switch method {
        case .get:
            return try await performGetRequest(endpoint: endpoint, params: params)
        case .post:
            return try await performPostRequest(endpoint: endpoint, body: body)
        }
    }

    private func performGetRequest<T: Codable>(endpoint: String, params: [String: Any]?) async throws -> T  {
        let urlString = "\(baseUrl)\(endpoint)"
        var urlComponents = URLComponents(string: urlString)
        var queryItems = [URLQueryItem]()
        if let params = params {
            for (key, value) in params {
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
            urlComponents?.queryItems = queryItems
        }

        guard let url = urlComponents?.url else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if !(200...299).contains(httpResponse.statusCode) {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    func performPostRequest<T: Codable>(endpoint: String, body: [String: Any]?) async throws -> T {
        let urlString = "\(BaseURL.jsonPlaceHolder.url)\(endpoint)"
        let urlComponents = URLComponents(string: urlString)
        guard let url = urlComponents?.url else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue

        if let body = body {
            let data = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = data
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if !(200...299).contains(httpResponse.statusCode) {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
