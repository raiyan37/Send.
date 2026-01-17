//
//  ProgressDashboardView.swift
//  RockClimber
//
//  Created on 2026-01-17
//

import SwiftUI
import Charts

struct ProgressDashboardView: View {
    @State private var selectedTimeRange = "Month"
    let timeRanges = ["Week", "Month", "Year", "All"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // time range selector
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(timeRanges, id: \.self) { range in
                        Text(range).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // grade progression chart
                VStack(alignment: .leading, spacing: 10) {
                    Text("Grade Progression")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    GradeProgressionChart()
                        .frame(height: 200)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        .padding(.horizontal)
                }
                
                // stats overview
                VStack(alignment: .leading, spacing: 10) {
                    Text("Overview")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        StatCard(title: "Total Climbs", value: "142", icon: "figure.climbing", color: .blue)
                        StatCard(title: "Success Rate", value: "73%", icon: "checkmark.circle", color: .green)
                        StatCard(title: "Current Grade", value: "V4", icon: "chart.line.uptrend.xyaxis", color: .orange)
                        StatCard(title: "Sessions", value: "28", icon: "calendar", color: .purple)
                    }
                    .padding(.horizontal)
                }
                
                // send pyramid
                VStack(alignment: .leading, spacing: 10) {
                    Text("Send Pyramid")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    SendPyramidView()
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        .padding(.horizontal)
                }
                
                // session history
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Sessions")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(0..<5) { index in
                        SessionHistoryCard(
                            date: Date().addingTimeInterval(-Double(index) * 86400 * 3),
                            duration: "2h 15m",
                            climbs: 12 - index,
                            grade: "V\(4 - index/2)"
                        )
                    }
                    .padding(.horizontal)
                }
                
                // weakness heatmap
                VStack(alignment: .leading, spacing: 10) {
                    Text("Weakness Analysis")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    WeaknessHeatmapView()
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        .padding(.horizontal)
                }
                
                // training suggestions
                VStack(alignment: .leading, spacing: 10) {
                    Text("Training Suggestions")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TrainingSuggestionCard(
                        title: "Improve Overhang Technique",
                        description: "Focus on hip positioning and core tension on steep walls",
                        priority: "High"
                    )
                    
                    TrainingSuggestionCard(
                        title: "Increase Finger Strength",
                        description: "Add hangboard sessions to improve crimp strength",
                        priority: "Medium"
                    )
                    
                    TrainingSuggestionCard(
                        title: "Work on Endurance",
                        description: "Try longer boulder circuits to build power endurance",
                        priority: "Low"
                    )
                }
                .padding(.horizontal)
                
                // injury tracking
                VStack(alignment: .leading, spacing: 10) {
                    Text("Injury Log")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    InjuryLogCard(
                        bodyPart: "Left Finger A2",
                        status: "Recovering",
                        daysAgo: 14
                    )
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.top)
        }
        .navigationTitle("Progress")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}

struct GradeProgressionChart: View {
    var body: some View {
        // placeholder chart
        GeometryReader { geometry in
            Path { path in
                let points: [(Double, Double)] = [
                    (0.1, 0.3), (0.25, 0.35), (0.4, 0.45),
                    (0.55, 0.5), (0.7, 0.6), (0.85, 0.7)
                ]
                
                for (index, point) in points.enumerated() {
                    let x = geometry.size.width * point.0
                    let y = geometry.size.height * (1 - point.1)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            
            // grade labels
            VStack {
                Spacer()
                HStack {
                    ForEach(["V1", "V2", "V3", "V4", "V5"], id: \.self) { grade in
                        Text(grade)
                            .font(.caption)
                        if grade != "V5" { Spacer() }
                    }
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct SendPyramidView: View {
    let pyramidData = [
        ("V6", 2),
        ("V5", 5),
        ("V4", 12),
        ("V3", 23),
        ("V2", 35)
    ]
    
    var body: some View {
        VStack(spacing: 5) {
            ForEach(pyramidData, id: \.0) { grade, count in
                HStack {
                    Text(grade)
                        .font(.caption)
                        .frame(width: 40, alignment: .leading)
                    
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 25)
                            .cornerRadius(5)
                        
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: CGFloat(count) * 8, height: 25)
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

struct SessionHistoryCard: View {
    let date: Date
    let duration: String
    let climbs: Int
    let grade: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(date, style: .date)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(climbs) climbs • \(duration)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(grade)
                .font(.headline)
                .padding(8)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct WeaknessHeatmapView: View {
    let weaknesses = [
        ("Overhangs", 0.3),
        ("Crimps", 0.5),
        ("Slopers", 0.7),
        ("Dynos", 0.4),
        ("Endurance", 0.6)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(weaknesses, id: \.0) { type, strength in
                HStack {
                    Text(type)
                        .font(.subheadline)
                        .frame(width: 100, alignment: .leading)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 20)
                                .cornerRadius(5)
                            
                            Rectangle()
                                .fill(heatmapColor(for: strength))
                                .frame(width: geometry.size.width * strength, height: 20)
                                .cornerRadius(5)
                        }
                    }
                    .frame(height: 20)
                }
            }
        }
    }
    
    func heatmapColor(for value: Double) -> Color {
        if value < 0.4 { return .red }
        else if value < 0.7 { return .orange }
        else { return .green }
    }
}

struct TrainingSuggestionCard: View {
    let title: String
    let description: String
    let priority: String
    
    var priorityColor: Color {
        switch priority {
        case "High": return .red
        case "Medium": return .orange
        case "Low": return .green
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(priority)
                    .font(.caption)
                    .padding(5)
                    .background(priorityColor.opacity(0.2))
                    .foregroundColor(priorityColor)
                    .cornerRadius(5)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct InjuryLogCard: View {
    let bodyPart: String
    let status: String
    let daysAgo: Int
    
    var body: some View {
        HStack {
            Image(systemName: "bandage")
                .font(.title2)
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(bodyPart)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(status) • \(daysAgo) days ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                // TODO: view injury details
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    NavigationView {
        ProgressDashboardView()
    }
}
