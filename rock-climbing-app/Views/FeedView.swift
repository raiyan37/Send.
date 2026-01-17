//
//  FeedView.swift
//  RockClimber
//
//  Created on 2026-01-17
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

private extension Color {
    static var platformBackground: Color {
        #if canImport(UIKit)
        return Color(uiColor: .systemBackground)
        #elseif canImport(AppKit)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color.white
        #endif
    }
}

struct FeedView: View {
    @State private var selectedFilter = "All"
    let filters = ["All", "Friends", "Following", "My Gym"]
    
    var body: some View {
        VStack(spacing: 0) {
            // filter bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(filters, id: \.self) { filter in
                        FilterButton(
                            title: filter,
                            isSelected: selectedFilter == filter,
                            action: { selectedFilter = filter }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            .background(Color.platformBackground)
            
            Divider()
            
            // posts feed
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(0..<10) { index in
                        PostCard(
                            userName: "Climber \(index + 1)",
                            userAvatar: "person.circle.fill",
                            timeAgo: "\(index + 1)h ago",
                            route: "V\((index % 6) + 2)",
                            gym: "Local Climbing Gym",
                            videoThumbnail: "photo",
                            caption: "Finally sent this project! 🎉",
                            likes: Int.random(in: 10...150),
                            comments: Int.random(in: 2...30)
                        )
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Feed")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
#if !os(macOS)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // TODO: open filters/settings
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
        #endif
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct PostCard: View {
    let userName: String
    let userAvatar: String
    let timeAgo: String
    let route: String
    let gym: String
    let videoThumbnail: String
    let caption: String
    let likes: Int
    let comments: Int
    
    @State private var isLiked = false
    @State private var likeCount: Int
    
    init(userName: String, userAvatar: String, timeAgo: String, route: String, gym: String, videoThumbnail: String, caption: String, likes: Int, comments: Int) {
        self.userName = userName
        self.userAvatar = userAvatar
        self.timeAgo = timeAgo
        self.route = route
        self.gym = gym
        self.videoThumbnail = videoThumbnail
        self.caption = caption
        self.likes = likes
        self.comments = comments
        _likeCount = State(initialValue: likes)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // header
            HStack {
                Image(systemName: userAvatar)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(userName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("\(gym) • \(timeAgo)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // route grade badge
                Text(route)
                    .font(.headline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            // video thumbnail
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(9/16, contentMode: .fit)
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // action buttons
            HStack(spacing: 20) {
                Button(action: {
                    isLiked.toggle()
                    likeCount += isLiked ? 1 : -1
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .primary)
                        Text("\(likeCount)")
                            .font(.subheadline)
                    }
                }
                
                Button(action: {
                    // TODO: open comments
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "bubble.right")
                        Text("\(comments)")
                            .font(.subheadline)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    // TODO: share post
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            .padding(.horizontal)
            .foregroundColor(.primary)
            
            // caption
            if !caption.isEmpty {
                Text(caption)
                    .font(.subheadline)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 10)
        .background(Color.platformBackground)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#Preview {
    NavigationView {
        FeedView()
    }
}
