//
//  HTTPSetup.swift
//  Send
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

    private enum DefaultTimeouts {
        static let jsonRequest: TimeInterval = 30
        static let upload: TimeInterval = 180
    }

    private enum DefaultsKeys {
        static let backendIPAddress = "backend_ip_address"
        static let backendPort = "backend_port"
    }

    private var baseURL: URL {
        userDefaultsBaseURL() ?? infoPlistBaseURL() ?? URL(string: "http://localhost:8000")!
    }

    private func userDefaultsBaseURL() -> URL? {
        let defaults = UserDefaults.standard
        let rawAddress = defaults.string(forKey: DefaultsKeys.backendIPAddress)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let rawAddress, !rawAddress.isEmpty else { return nil }

        let rawPort = defaults.string(forKey: DefaultsKeys.backendPort)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let portFromDefaults = rawPort.flatMap(Int.init)

        var scheme = "http"
        var host = rawAddress
        var portFromAddress: Int?

        if rawAddress.contains("://"), let url = URL(string: rawAddress), let parsedHost = url.host {
            scheme = url.scheme ?? scheme
            host = parsedHost
            portFromAddress = url.port
        } else if rawAddress.contains(":"),
                  !rawAddress.contains("://"),
                  rawAddress.filter({ $0 == ":" }).count == 1,
                  let lastColon = rawAddress.lastIndex(of: ":") {
            let hostPart = String(rawAddress[..<lastColon])
            let portPart = String(rawAddress[rawAddress.index(after: lastColon)...])
            if let parsedPort = Int(portPart), !hostPart.isEmpty {
                host = hostPart
                portFromAddress = parsedPort
            }
        }

        let resolvedPort = portFromDefaults ?? portFromAddress ?? 8000
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = resolvedPort
        return components.url
    }

    private func infoPlistBaseURL() -> URL? {
        let urlString = (Bundle.main.object(forInfoDictionaryKey: "BackendBaseURL") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let urlString, !urlString.isEmpty else { return nil }
        return URL(string: urlString)
    }

    private let apiKey: String = {
        (Bundle.main.object(forInfoDictionaryKey: "BackendAPIKey") as? String) ?? ""
    }()

    private func makeURL(path: String) -> URL {
        let normalizedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return baseURL.appendingPathComponent(normalizedPath)
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

    private func makeNetworkErrorMessage(_ error: URLError) -> String {
        let base = baseURL.absoluteString
        switch error.code {
        case .timedOut:
            return "Request timed out contacting backend at \(base)"
        case .cannotFindHost, .dnsLookupFailed:
            return "Cannot find backend host (\(base)). Check the backend IP/port in iOS Settings and ensure your iPhone is on the same network."
        case .cannotConnectToHost:
            return "Cannot connect to backend at \(base). Ensure the server is running and listening on 0.0.0.0 (not just localhost)."
        case .notConnectedToInternet, .networkConnectionLost:
            return "Network connection issue. Verify your iPhone can reach the Mac running the backend (\(base))."
        default:
            return error.localizedDescription
        }
    }

    func request<T: Decodable>(
        path: String,
        method: HTTPMethod,
        body: Encodable? = nil,
        timeoutInterval: TimeInterval = DefaultTimeouts.jsonRequest
    ) async throws -> T {
        var request = URLRequest(url: makeURL(path: path))
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeoutInterval
        
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

        #if DEBUG
        print("[API] \(method.rawValue) \(request.url?.absoluteString ?? path)")
        #endif

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let error as URLError {
            throw APIError(message: makeNetworkErrorMessage(error))
        }

        guard let http = response as? HTTPURLResponse,
              200..<300 ~= http.statusCode else {
            throw APIError(message: errorMessage(from: data))
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }
    
    func requestData(
        path: String,
        method: HTTPMethod,
        timeoutInterval: TimeInterval = DefaultTimeouts.jsonRequest
    ) async throws -> Data {
        var request = URLRequest(url: makeURL(path: path))
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeoutInterval
        if !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        }
        
        #if DEBUG
        print("[API] \(method.rawValue) \(request.url?.absoluteString ?? path)")
        #endif

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let error as URLError {
            throw APIError(message: makeNetworkErrorMessage(error))
        }
        
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
        additionalFields: [String: String] = [:],
        timeoutInterval: TimeInterval = DefaultTimeouts.upload
    ) async throws -> Data {
        var request = URLRequest(url: makeURL(path: path))
        request.httpMethod = HTTPMethod.post.rawValue
        request.timeoutInterval = timeoutInterval
        
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
        
        #if DEBUG
        print("[API] POST \(request.url?.absoluteString ?? path) (multipart)")
        #endif

        let (responseData, response): (Data, URLResponse)
        do {
            (responseData, response) = try await URLSession.shared.data(for: request)
        } catch let error as URLError {
            throw APIError(message: makeNetworkErrorMessage(error))
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError(message: errorMessage(from: responseData))
        }
        
        return responseData
    }
}
