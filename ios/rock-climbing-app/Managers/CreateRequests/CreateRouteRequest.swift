//
//  CreateRouteRequest.swift
//  Send
//
//  Created on 2026-01-17
//

import Foundation

// example implementation for route creation requests
class CreateRouteRequest {
    
    struct CreateRouteBody: Encodable {
        let name: String
        let grade: ClimbingGrade?
        let type: RouteType
        let gymId: String?
        let gymName: String?
    }
    
    // create route
    static func createRoute(body: CreateRouteBody) async throws -> SaveRouteResponseBody {
        return try await APIClient.shared.request(
            path: "/api/routes",
            method: .post,
            body: body
        )
    }
    
    // upload route image for ai analysis
    static func uploadRouteImage(
        routeId: String,
        imageData: Data,
        filename: String
    ) async throws -> SaveRouteResponseBody {
        let responseData = try await APIClient.shared.uploadMultipart(
            path: "/api/routes/\(routeId)/upload",
            data: imageData,
            filename: filename,
            mimeType: "image/jpeg",
            additionalFields: ["routeId": routeId]
        )
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SaveRouteResponseBody.self, from: responseData)
    }
    
    // request ai analysis for route
    static func requestAnalysis(routeId: String) async throws -> GenericRequestResponse {
        return try await APIClient.shared.request(
            path: "/api/routes/\(routeId)/analyze",
            method: .post
        )
    }
}
