//
//  CreateUserRequest.swift
//  RockClimber
//
//  Created on 2026-01-17
//

import Foundation

// example implementation for user creation requests
class CreateUserRequest {
    
    struct CreateUserBody: Encodable {
        let email: String
        let firstName: String
        let lastName: String
        let photoURL: String?
        let googleId: String?
    }
    
    // create new user account
    static func createUser(body: CreateUserBody) async throws -> AuthResponseBody {
        return try await APIClient.shared.request(
            path: "/api/users",
            method: .post,
            body: body
        )
    }
    
    // authenticate with google oauth
    static func authenticateGoogle(idToken: String) async throws -> AuthResponseBody {
        struct GoogleAuthBody: Encodable {
            let idToken: String
        }
        
        return try await APIClient.shared.request(
            path: "/api/auth/google",
            method: .post,
            body: GoogleAuthBody(idToken: idToken)
        )
    }
}
