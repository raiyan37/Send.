//
//  DeleteUserRequest.swift
//  Send
//
//  Created on 2026-01-17
//

import Foundation

// example implementation for user deletion requests
class DeleteUserRequest {
    
    // delete user account
    static func deleteAccount(userId: String) async throws -> GenericRequestResponse {
        return try await APIClient.shared.request(
            path: "/api/users/\(userId)",
            method: .delete
        )
    }
    
    // remove follower
    static func removeFollower(userId: String, followerId: String) async throws -> GenericRequestResponse {
        return try await APIClient.shared.request(
            path: "/api/users/\(userId)/followers/\(followerId)",
            method: .delete
        )
    }
}
