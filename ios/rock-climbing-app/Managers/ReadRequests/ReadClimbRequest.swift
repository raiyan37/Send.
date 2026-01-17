//
//  ReadClimbRequest.swift
//  RockClimber
//
//  Created on 2026-01-17
//

import Foundation

// example implementation for climb read requests
class ReadClimbRequest {
    
    // get climb analysis
    static func getAnalysis(climbId: String) async throws -> ClimbAnalysisResponseBody {
        return try await APIClient.shared.request(
            path: "/api/climbs/\(climbId)/analysis",
            method: .get
        )
    }
    
    // get user's climbs
    static func getUserClimbs(userId: String, page: Int = 1) async throws -> [ClimbAnalysisResponseBody] {
        return try await APIClient.shared.request(
            path: "/api/users/\(userId)/climbs?page=\(page)",
            method: .get
        )
    }
    
    // get route analysis
    static func getRouteAnalysis(routeId: String) async throws -> RouteAnalysisResponseBody {
        return try await APIClient.shared.request(
            path: "/api/routes/\(routeId)/analysis",
            method: .get
        )
    }
}
