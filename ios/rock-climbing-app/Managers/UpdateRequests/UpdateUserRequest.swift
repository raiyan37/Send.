//
//  UpdateUserRequest.swift
//  Send
//
//  Created on 2026-01-17
//

import Foundation

// example implementation for user update requests
class UpdateUserRequest {
    
    struct UpdateProfileBody: Encodable {
        let firstName: String?
        let lastName: String?
        let photoURL: String?
    }
    
    // update user profile
    static func updateProfile(userId: String, body: UpdateProfileBody) async throws -> GenericRequestResponse {
        return try await APIClient.shared.request(
            path: "/api/users/\(userId)",
            method: .put,
            body: body
        )
    }
    
    // update privacy settings
    struct UpdatePrivacyBody: Encodable {
        let profilePublic: Bool?
        let showInLeaderboard: Bool?
    }
    
    static func updatePrivacy(userId: String, body: UpdatePrivacyBody) async throws -> GenericRequestResponse {
        return try await APIClient.shared.request(
            path: "/api/users/\(userId)/privacy",
            method: .put,
            body: body
        )
    }
    
    // follow/unfollow user
    static func followUser(userId: String, targetUserId: String) async throws -> GenericRequestResponse {
        return try await APIClient.shared.request(
            path: "/api/users/\(userId)/follow/\(targetUserId)",
            method: .post
        )
    }
    
    static func unfollowUser(userId: String, targetUserId: String) async throws -> GenericRequestResponse {
        return try await APIClient.shared.request(
            path: "/api/users/\(userId)/unfollow/\(targetUserId)",
            method: .post
        )
    }
}
