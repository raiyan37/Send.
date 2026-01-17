//
//  CreateClimbRequest.swift
//  RockClimber
//
//  Created on 2026-01-17
//

import Foundation

// example implementation for climb creation requests
class CreateClimbRequest {
    
    struct CreateClimbBody: Encodable {
        let userId: String
        let routeId: String
        let status: ClimbStatus
        let attempts: Int
        let notes: String?
    }
    
    // create climb record
    static func createClimb(body: CreateClimbBody) async throws -> SaveClimbResponseBody {
        return try await APIClient.shared.request(
            path: "/api/climbs",
            method: .post,
            body: body
        )
    }
    
    // upload climb video for analysis
    static func uploadClimbVideo(
        climbId: String,
        videoData: Data,
        filename: String,
        userId: String
    ) async throws -> SaveClimbResponseBody {
        let responseData = try await APIClient.shared.uploadMultipart(
            path: "/api/climbs/\(climbId)/upload",
            data: videoData,
            filename: filename,
            mimeType: "video/mp4",
            additionalFields: ["userId": userId]
        )
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SaveClimbResponseBody.self, from: responseData)
    }
    
    // create social post from climb
    struct CreatePostBody: Encodable {
        let climbId: String
        let caption: String?
    }
    
    static func createPost(body: CreatePostBody) async throws -> GenericRequestResponse {
        return try await APIClient.shared.request(
            path: "/api/posts",
            method: .post,
            body: body
        )
    }
}
