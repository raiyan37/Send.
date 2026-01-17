//
//  LoginView.swift
//  RockClimber
//
//  Created on 2026-01-17
//

import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // app logo/title
            VStack(spacing: 10) {
                Image(systemName: "figure.climbing")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("RockClimber")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Track your climbing progress")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // google sign in button placeholder
            Button(action: {
                isLoggedIn = true
            }) {
                HStack {
                    Image(systemName: "globe")
                        .font(.title2)
                    
                    Text("Sign in with Google")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(10)
                .shadow(radius: 2)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
