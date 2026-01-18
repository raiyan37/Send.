//
//  ProfileView.swift
//  Send
//
//  Created on 2026-01-17
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("userFirstName") private var userFirstName = ""
    @AppStorage("userLastName") private var userLastName = ""
    @AppStorage("userPhotoURL") private var userPhotoURL = ""
    @State private var selectedTab = "Stats"
    let tabs = ["Stats", "History", "Settings"]
    
    private var displayName: String {
        let name = "\(userFirstName) \(userLastName)".trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "Climber" : name
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // profile header
                VStack(spacing: 15) {
                    // avatar
                    if let url = URL(string: userPhotoURL), !userPhotoURL.isEmpty {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 100))
                                .foregroundColor(.blue)
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.blue)
                    }
                    
                    // name and stats summary
                    VStack(spacing: 5) {
                        Text(displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Member since Jan 2024")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // quick stats
                    HStack(spacing: 40) {
                        VStack(spacing: 5) {
                            Text("142")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("Climbs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 5) {
                            Text("V4")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("Max Grade")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 5) {
                            Text("245")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("Followers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // edit profile button
                    Button(action: {
                        // TODO: edit profile
                    }) {
                        Text("Edit Profile")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                }
                .padding()
                
                // tab selector
                Picker("View", selection: $selectedTab) {
                    ForEach(tabs, id: \.self) { tab in
                        Text(tab).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // tab content
                Group {
                    if selectedTab == "Stats" {
                        StatsTabView()
                    } else if selectedTab == "History" {
                        HistoryTabView()
                    } else {
                        SettingsTabView()
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .navigationTitle("Profile")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct StatsTabView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // send pyramid
            VStack(alignment: .leading, spacing: 10) {
                Text("Send Pyramid")
                    .font(.headline)
                
                SendPyramidVisualization()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            
            // climbing style preferences
            VStack(alignment: .leading, spacing: 10) {
                Text("Style Preferences")
                    .font(.headline)
                
                StylePreferenceRow(style: "Technical", percentage: 85)
                StylePreferenceRow(style: "Power", percentage: 60)
                StylePreferenceRow(style: "Endurance", percentage: 70)
                StylePreferenceRow(style: "Dynamic", percentage: 45)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            
            // personal records
            VStack(alignment: .leading, spacing: 10) {
                Text("Personal Records")
                    .font(.headline)
                
                PersonalRecordRow(title: "Highest Grade", value: "V6", date: "Dec 2025")
                PersonalRecordRow(title: "Most Climbs/Session", value: "18", date: "Nov 2025")
                PersonalRecordRow(title: "Longest Session", value: "3h 45m", date: "Oct 2025")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
        }
    }
}

struct HistoryTabView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Activity")
                .font(.headline)
            
            ForEach(0..<8) { index in
                HistoryItemRow(
                    route: "V\((index % 6) + 1)",
                    gym: "Local Climbing Gym",
                    date: Date().addingTimeInterval(-Double(index) * 86400),
                    completed: index % 3 != 0
                )
            }
        }
    }
}

struct SettingsTabView: View {
    @AppStorage("authToken") private var authToken = ""
    @AppStorage("currentUserId") private var currentUserId = ""
    @AppStorage("userFirstName") private var userFirstName = ""
    @AppStorage("userLastName") private var userLastName = ""
    @AppStorage("userPhotoURL") private var userPhotoURL = ""
    @State private var notificationsEnabled = true
    @State private var profilePublic = true
    @State private var showInLeaderboard = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // privacy settings
            VStack(alignment: .leading, spacing: 15) {
                Text("Privacy")
                    .font(.headline)
                
                Toggle("Public Profile", isOn: $profilePublic)
                Toggle("Show in Leaderboard", isOn: $showInLeaderboard)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            
            // notification settings
            VStack(alignment: .leading, spacing: 15) {
                Text("Notifications")
                    .font(.headline)
                
                Toggle("Push Notifications", isOn: $notificationsEnabled)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            
            // injury history
            VStack(alignment: .leading, spacing: 15) {
                Text("Injury History")
                    .font(.headline)
                
                Button(action: {
                    // TODO: view injury history
                }) {
                    HStack {
                        Image(systemName: "bandage")
                        Text("View Injury Log")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            
            // account actions
            VStack(spacing: 15) {
                Button(action: {
                    // TODO: export data
                }) {
                    Text("Export My Data")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    signOut()
                }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private func signOut() {
        authToken = ""
        currentUserId = ""
        userFirstName = ""
        userLastName = ""
        userPhotoURL = ""
    }
}

struct SendPyramidVisualization: View {
    let pyramidData = [
        ("V6", 2),
        ("V5", 5),
        ("V4", 12),
        ("V3", 23),
        ("V2", 35)
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(pyramidData, id: \.0) { grade, count in
                HStack {
                    Text(grade)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 40, alignment: .leading)
                    
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 30)
                            .cornerRadius(5)
                        
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: CGFloat(count) * 7, height: 30)
                            .cornerRadius(5)
                        
                        Text("\(count)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                    }
                }
            }
        }
    }
}

struct StylePreferenceRow: View {
    let style: String
    let percentage: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(style)
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(percentage)%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * CGFloat(percentage) / 100, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

struct PersonalRecordRow: View {
    let title: String
    let value: String
    let date: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 5)
    }
}

struct HistoryItemRow: View {
    let route: String
    let gym: String
    let date: Date
    let completed: Bool
    
    var body: some View {
        HStack {
            Image(systemName: completed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(completed ? .green : .red)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(route)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(gym) • \(date, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
}
