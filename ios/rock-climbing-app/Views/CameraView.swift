//
//  CameraView.swift
//  RockClimber
//
//  Created on 2026-01-17
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var isRecording = false
    @State private var showGrid = true
    @State private var captureMode: CaptureMode = .photo
    
    enum CaptureMode {
        case photo
        case video
    }
    
    var body: some View {
        ZStack {
            // actual camera preview
            if cameraManager.isAuthorized {
                CameraPreviewView(session: cameraManager.session)
                    .ignoresSafeArea()
                    .onAppear {
                        cameraManager.startSession()
                    }
                    .onDisappear {
                        cameraManager.stopSession()
                    }
            } else {
                // fallback if camera not authorized
                Color.black
                    .ignoresSafeArea()
                
                VStack {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.5))
                    Text("Camera access required")
                        .foregroundColor(.white)
                        .padding()
                    Text("Please enable camera access in Settings")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // grid overlay
            if showGrid {
                GridOverlay()
            }
            
            VStack {
                // top controls
                HStack {
                    Button(action: {
                        showGrid.toggle()
                    }) {
                        Image(systemName: showGrid ? "grid" : "grid.circle")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        cameraManager.switchCamera()
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                
                Spacer()
                
                // bottom controls
                VStack(spacing: 20) {
                    // mode selector
                    HStack(spacing: 30) {
                        Button("Photo") {
                            captureMode = .photo
                        }
                        .foregroundColor(captureMode == .photo ? .yellow : .white)
                        .fontWeight(captureMode == .photo ? .bold : .regular)
                        
                        Button("Video") {
                            captureMode = .video
                        }
                        .foregroundColor(captureMode == .video ? .yellow : .white)
                        .fontWeight(captureMode == .video ? .bold : .regular)
                    }
                    
                    // capture button
                    Button(action: {
                        handleCapture()
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 70, height: 70)
                            
                            Circle()
                                .fill(isRecording ? Color.red : Color.white)
                                .frame(width: isRecording ? 30 : 60, height: isRecording ? 30 : 60)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Camera")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private func handleCapture() {
        if captureMode == .photo {
            cameraManager.takePhoto()
        } else {
            isRecording.toggle()
            // TODO: implement video recording
        }
    }
}

struct GridOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                // vertical lines
                let thirdWidth = geometry.size.width / 3
                path.move(to: CGPoint(x: thirdWidth, y: 0))
                path.addLine(to: CGPoint(x: thirdWidth, y: geometry.size.height))
                path.move(to: CGPoint(x: thirdWidth * 2, y: 0))
                path.addLine(to: CGPoint(x: thirdWidth * 2, y: geometry.size.height))
                
                // horizontal lines
                let thirdHeight = geometry.size.height / 3
                path.move(to: CGPoint(x: 0, y: thirdHeight))
                path.addLine(to: CGPoint(x: geometry.size.width, y: thirdHeight))
                path.move(to: CGPoint(x: 0, y: thirdHeight * 2))
                path.addLine(to: CGPoint(x: geometry.size.width, y: thirdHeight * 2))
            }
            .stroke(Color.white.opacity(0.5), lineWidth: 1)
        }
    }
}

#Preview {
    NavigationView {
        CameraView()
    }
}
