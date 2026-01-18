//
//  DeleteClimbRequest.swift
//  Send
//
//  Created on 2026-01-17
//

import Foundation

// example implementation for climb deletion requests
class DeleteClimbRequest {
    
    // delete climb record
    static func deleteClimb(climbId: String) async throws -> GenericRequestResponse {
        return try await APIClient.shared.request(
            path: "/api/climbs/\(climbId)",
            method: .delete
        )
    }
    
    // delete post
    static func deletePost(postId: String) async throws -> GenericRequestResponse {
        return try await APIClient.shared.request(
            path: "/api/posts/\(postId)",
            method: .delete
        )
    }
    
    // delete comment
    static func deleteComment(commentId: String) async throws -> GenericRequestResponse {
        return try await APIClient.shared.request(
            path: "/api/comments/\(commentId)",
            method: .delete
        )
    }
}
