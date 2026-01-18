//
//  ReadUserRequest.swift
//  Send
//
//  Created on 2026-01-17
//

import Foundation

// example implementation for user read requests
class ReadUserRequest {
    
    // get user profile
    static func getProfile(userId: String) async throws -> ProfileResponseBody {
        return try await APIClient.shared.request(
            path: "/api/users/\(userId)/profile",
            method: .get
        )
    }
    
    // get user feed
    static func getFeed(userId: String, page: Int = 1, filter: String = "all") async throws -> FeedResponseBody {
        return try await APIClient.shared.request(
            path: "/api/users/\(userId)/feed?page=\(page)&filter=\(filter)",
            method: .get
        )
    }
    
    // get user progress data
    static func getProgress(userId: String, timeRange: String = "month") async throws -> ProgressResponseBody {
        return try await APIClient.shared.request(
            path: "/api/users/\(userId)/progress?range=\(timeRange)",
            method: .get
        )
    }
}
