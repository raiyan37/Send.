//
//  RouteAnalysisView.swift
//  RockClimber
//
//  Created on 2026-01-17
//

import SwiftUI
import UIKit

struct RouteAnalysisView: View {
    @State private var showBoundingBoxes = true
    @State private var showRouteLine = true
    @State private var selectedBeta = 0

    let analyzedImage: UIImage?

    init(analyzedImage: UIImage? = nil) {
        self.analyzedImage = analyzedImage
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // wall image with overlays
                ZStack {
                    if let analyzedImage {
                        Image(uiImage: analyzedImage)
                            .resizable()
                            .scaledToFit()
                    } else {
                        // placeholder wall image
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(3/4, contentMode: .fit)
                        
                        // detected holds overlay
                        if showBoundingBoxes {
                            HoldBoundingBoxesOverlay()
                        }
                        
                        // suggested route line
                        if showRouteLine {
                            RouteLineOverlay()
                        }
                    }
                    
                    // difficulty badge
                    VStack {
                        HStack {
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 5) {
                                Text("V4")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text("Predicted")
                                    .font(.caption)
                            }
                            .padding(10)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                        }
                        
                        Spacer()
                    }
                }
                
                if analyzedImage == nil {
                    // controls (demo overlays only)
                    HStack(spacing: 20) {
                        Toggle("Holds", isOn: $showBoundingBoxes)
                        Toggle("Route", isOn: $showRouteLine)
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                
                // beta options
                VStack(alignment: .leading, spacing: 10) {
                    Text("Beta Options")
                        .font(.headline)
                    
                    ForEach(0..<3) { index in
                        BetaOptionCard(
                            betaNumber: index + 1,
                            difficulty: ["Easy", "Medium", "Hard"][index],
                            description: "Alternative route suggestion \(index + 1)",
                            isSelected: selectedBeta == index
                        )
                        .onTapGesture {
                            selectedBeta = index
                        }
                    }
                }
                .padding()
                
                // action buttons
                HStack(spacing: 15) {
                    Button(action: {
                        // TODO: start climb
                    }) {
                        Text("Start Climb")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // TODO: save route
                    }) {
                        Image(systemName: "bookmark")
                            .font(.title2)
                            .frame(width: 50)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Route Analysis")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct HoldBoundingBoxesOverlay: View {
    var body: some View {
        // placeholder for hold detection bounding boxes
        GeometryReader { geometry in
            ForEach(0..<8) { index in
                Rectangle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: 40, height: 40)
                    .position(
                        x: CGFloat.random(in: 20...(geometry.size.width - 20)),
                        y: CGFloat.random(in: 20...(geometry.size.height - 20))
                    )
            }
        }
    }
}

struct RouteLineOverlay: View {
    var body: some View {
        // placeholder for suggested route line
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.9))
                path.addLine(to: CGPoint(x: geometry.size.width * 0.4, y: geometry.size.height * 0.7))
                path.addLine(to: CGPoint(x: geometry.size.width * 0.6, y: geometry.size.height * 0.5))
                path.addLine(to: CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.3))
                path.addLine(to: CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.1))
            }
            .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [10, 5]))
        }
    }
}

struct BetaOptionCard: View {
    let betaNumber: Int
    let difficulty: String
    let description: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Beta \(betaNumber)")
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(difficulty)
                .font(.caption)
                .padding(5)
                .background(difficultyColor.opacity(0.2))
                .foregroundColor(difficultyColor)
                .cornerRadius(5)
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
    
    var difficultyColor: Color {
        switch difficulty {
        case "Easy": return .green
        case "Medium": return .orange
        case "Hard": return .red
        default: return .gray
        }
    }
}

#Preview {
    NavigationView {
        RouteAnalysisView(analyzedImage: nil)
    }
}
