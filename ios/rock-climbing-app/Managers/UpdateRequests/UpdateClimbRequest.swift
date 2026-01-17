//
//  UpdateClimbRequest.swift
//  RockClimber
//
//  Created on 2026-01-17
//

import Foundation

// example implementation for climb update requests
class UpdateClimbRequest {
    
    struct UpdateClimbBody: Encodable {
        let status: ClimbStatus?
        let attempts: Int?
        let notes: String?
    }
    
    // update climb record
    static func updateClimb(climbId: String, body: UpdateClimbBody) async throws -> GenericRequestResponse {
        return try await APIClient.shared.request(
            path: "/api/climbs/\(climbId)",
            method: .put,
            body: body
        )
    }
    
    // like/unlike post
    static func likePost(postId: String, userId: String) async throws -> GenericRequestResponse {
        return try await APIClient.shared.request(
            path: "/api/posts/\(postId)/like",
            method: .post,
            body: ["userId": userId]
        )
    }
    
    static func unlikePost(postId: String, userId: String) async throws -> GenericRequestResponse {
        return try await APIClient.shared.request(
            path: "/api/posts/\(postId)/unlike",
            method: .post,
            body: ["userId": userId]
        )
    }
    
    // add comment to post
    struct AddCommentBody: Encodable {
        let userId: String
        let text: String
    }
    
    static func addComment(postId: String, body: AddCommentBody) async throws -> GenericRequestResponse {
        return try await APIClient.shared.request(
            path: "/api/posts/\(postId)/comments",
            method: .post,
            body: body
        )
    }
}
