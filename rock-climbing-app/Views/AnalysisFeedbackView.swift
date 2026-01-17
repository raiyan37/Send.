//
//  AnalysisFeedbackView.swift
//  RockClimber
//
//  Created on 2026-01-17
//

import SwiftUI
import AVKit

struct AnalysisFeedbackView: View {
    @State private var showPoseSkeleton = true
    @State private var selectedSection = 0
    
    let sections = ["Start", "Middle", "Crux", "Finish"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // video player with pose overlay
                ZStack {
                    // placeholder video player
                    Rectangle()
                        .fill(Color.black)
                        .aspectRatio(16/9, contentMode: .fit)
                        .overlay(
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.8))
                        )
                    
                    // pose skeleton overlay
                    if showPoseSkeleton {
                        PoseSkeletonOverlay()
                    }
                }
                
                // pose overlay toggle
                Toggle("Show Pose Analysis", isOn: $showPoseSkeleton)
                    .padding(.horizontal)
                
                Divider()
                
                // section selector
                VStack(alignment: .leading, spacing: 10) {
                    Text("Climb Sections")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(0..<sections.count, id: \.self) { index in
                                SectionButton(
                                    title: sections[index],
                                    isSelected: selectedSection == index,
                                    action: { selectedSection = index }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // technique scores
                VStack(alignment: .leading, spacing: 15) {
                    Text("Technique Scores")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TechniqueScoreRow(category: "Hip Position", score: 85, color: .green)
                    TechniqueScoreRow(category: "Arm Extension", score: 72, color: .orange)
                    TechniqueScoreRow(category: "Foot Placement", score: 90, color: .green)
                    TechniqueScoreRow(category: "Body Tension", score: 68, color: .orange)
                }
                .padding(.horizontal)
                
                Divider()
                
                // form corrections
                VStack(alignment: .leading, spacing: 15) {
                    Text("Form Corrections")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    CorrectionCard(
                        title: "Keep hips closer to wall",
                        description: "Your hips are too far from the wall, causing unnecessary arm strain.",
                        icon: "exclamationmark.triangle.fill",
                        iconColor: .orange
                    )
                    
                    CorrectionCard(
                        title: "Extend arms fully before moving",
                        description: "Reaching from a bent arm position reduces efficiency.",
                        icon: "exclamationmark.triangle.fill",
                        iconColor: .orange
                    )
                    
                    CorrectionCard(
                        title: "Great footwork!",
                        description: "Your precise foot placements are minimizing energy waste.",
                        icon: "checkmark.circle.fill",
                        iconColor: .green
                    )
                }
                .padding(.horizontal)
                
                Divider()
                
                // comparison to optimal beta
                VStack(alignment: .leading, spacing: 10) {
                    Text("Optimal Beta Comparison")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: 15) {
                        // your attempt
                        VStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 120)
                                .cornerRadius(10)
                                .overlay(
                                    Text("Your Attempt")
                                        .foregroundColor(.white)
                                )
                            Text("3 moves")
                                .font(.caption)
                        }
                        
                        // optimal beta
                        VStack {
                            Rectangle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(height: 120)
                                .cornerRadius(10)
                                .overlay(
                                    Text("Optimal Beta")
                                        .foregroundColor(.white)
                                )
                            Text("2 moves")
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                
                // progress comparison
                VStack(alignment: .leading, spacing: 10) {
                    Text("Progress vs Previous Attempts")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ProgressComparisonChart()
                }
                
                // action buttons
                HStack(spacing: 15) {
                    Button(action: {
                        // TODO: retry climb
                    }) {
                        Text("Try Again")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // TODO: share to feed
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .frame(width: 50)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle("Analysis")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct SectionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}

struct TechniqueScoreRow: View {
    let category: String
    let score: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(category)
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(score)%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(score) / 100, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

struct CorrectionCard: View {
    let title: String
    let description: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
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

struct ProgressComparisonChart: View {
    var body: some View {
        // placeholder progress chart
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(0..<5) { index in
                VStack {
                    Rectangle()
                        .fill(Color.blue.opacity(0.7))
                        .frame(width: 40, height: CGFloat([60, 75, 65, 85, 95][index]))
                        .cornerRadius(5)
                    
                    Text("A\(index + 1)")
                        .font(.caption2)
                }
            }
        }
        .frame(height: 120)
        .padding()
    }
}

#Preview {
    NavigationView {
        AnalysisFeedbackView()
    }
}

