//
//  HTTPSetup.swift
//  RockClimber
//
//  Created on 2026-01-17
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct APIError: Error {
    let message: String
}

struct GenericRequestResponse: Decodable {
    let message: String
}

struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    init<T: Encodable>(_ wrapped: T) {
        self.encodeFunc = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}

final class APIClient {
    static let shared = APIClient()
    private init() {}

    static let backendBaseURLOverrideKey = "BackendBaseURLOverride"
    private static let defaultBaseURLString = "http://127.0.0.1:8000"

    private var baseURL: URL {
        let overrideString = UserDefaults.standard.string(forKey: Self.backendBaseURLOverrideKey)
        let infoPlistString = Bundle.main.object(forInfoDictionaryKey: "BackendBaseURL") as? String

        let candidates = [
            overrideString,
            infoPlistString,
            Self.defaultBaseURLString
        ]

        for candidate in candidates {
            guard let candidate else { continue }
            let trimmed = candidate.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            let normalized = normalizeBaseURLString(trimmed)
            guard let url = URL(string: normalized), url.scheme != nil, url.host != nil else { continue }
            return url
        }

        return URL(string: Self.defaultBaseURLString)!
    }

    var baseURLString: String {
        baseURL.absoluteString
    }

    private var apiKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "BackendAPIKey") as? String) ?? ""
    }

    private func normalizeBaseURLString(_ urlString: String) -> String {
        if urlString.contains("://") {
            return urlString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        }
        return "http://\(urlString)".trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    private func makeURL(path: String) -> URL {
        let trimmedPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
        let relativePath = trimmedPath.hasPrefix("/") ? trimmedPath : "/\(trimmedPath)"
        return URL(string: relativePath, relativeTo: baseURL)?.absoluteURL ?? baseURL
    }

    private func errorMessage(from data: Data) -> String {
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let detail = json["detail"] as? String, !detail.isEmpty {
                return detail
            }
            if let message = json["message"] as? String, !message.isEmpty {
                return message
            }
        }
        if let text = String(data: data, encoding: .utf8), !text.isEmpty {
            return text
        }
        return "Request failed"
    }

    func request<T: Decodable>(
        path: String,
        method: HTTPMethod,
        body: Encodable? = nil
    ) async throws -> T {
        var request = URLRequest(url: makeURL(path: path))
        request.httpMethod = method.rawValue
        
        // standard headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        }

        if let body = body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              200..<300 ~= http.statusCode else {
            throw APIError(message: errorMessage(from: data))
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }
    
    func requestData(path: String, method: HTTPMethod) async throws -> Data {
        var request = URLRequest(url: makeURL(path: path))
        request.httpMethod = method.rawValue
        if !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError(message: errorMessage(from: data))
        }
        
        return data
    }
    
    // multipart form data upload for images/videos
    func uploadMultipart(
        path: String,
        data: Data,
        filename: String,
        mimeType: String,
        additionalFields: [String: String] = [:]
    ) async throws -> Data {
        var request = URLRequest(url: makeURL(path: path))
        request.httpMethod = HTTPMethod.post.rawValue
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        }
        
        var body = Data()
        
        // add additional fields
        for (key, value) in additionalFields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError(message: errorMessage(from: responseData))
        }
        
        return responseData
    }
}
