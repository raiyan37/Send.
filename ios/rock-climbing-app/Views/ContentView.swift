//
//  ContentView.swift
//  Send
//
//  Created on 2026-01-17
//

import SwiftUI

struct ContentView: View {
    @AppStorage("authToken") private var authToken = ""
    @State private var selectedTab = 0
    
    var body: some View {
        if authToken.isEmpty {
            LoginView()
        } else {
            TabView(selection: $selectedTab) {
                NavigationView {
                    HomeView()
                }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
                
                NavigationView {
                    CameraView()
                }
                .tabItem {
                    Label("Camera", systemImage: "camera.fill")
                }
                .tag(1)
                
                NavigationView {
                    ProgressDashboardView()
                }
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)
                
                NavigationView {
                    ProfileView()
                }
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
            }
        }
    }
}

#Preview {
    ContentView()
}
