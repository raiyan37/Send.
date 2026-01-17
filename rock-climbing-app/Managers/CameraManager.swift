//
//  CameraManager.swift
//  RockClimber
//
//  Created on 2026-01-17
//

import AVFoundation
import SwiftUI
import Combine

class CameraManager: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var error: CameraError?
    @Published var session = AVCaptureSession()
    
    private var videoOutput = AVCaptureMovieFileOutput()
    private var photoOutput = AVCapturePhotoOutput()
    private var currentCamera: AVCaptureDevice?
    
    enum CameraError: Error, LocalizedError {
        case unauthorized
        case cannotAddInput
        case cannotAddOutput
        case createCaptureInput
        
        var errorDescription: String? {
            switch self {
            case .unauthorized:
                return "Camera access is not authorized"
            case .cannotAddInput:
                return "Cannot add camera input"
            case .cannotAddOutput:
                return "Cannot add camera output"
            case .createCaptureInput:
                return "Cannot create camera input"
            }
        }
    }
    
    override init() {
        super.init()
        checkAuthorization()
    }
    
    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.setupCamera()
                    }
                }
            }
        default:
            isAuthorized = false
            error = .unauthorized
        }
    }
    
    func setupCamera() {
        session.beginConfiguration()
        
        // set session preset
        if session.canSetSessionPreset(.high) {
            session.sessionPreset = .high
        }
        
        // get the camera device
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            session.commitConfiguration()
            return
        }
        currentCamera = camera
        
        // add camera input
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
            } else {
                error = .cannotAddInput
            }
        } catch {
            self.error = .createCaptureInput
        }
        
        // add photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        // add video output
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        session.commitConfiguration()
    }
    
    func startSession() {
        if !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        if session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.stopRunning()
            }
        }
    }
    
    func switchCamera() {
        session.beginConfiguration()
        
        // remove existing input
        session.inputs.forEach { input in
            session.removeInput(input)
        }
        
        // get opposite camera
        let newPosition: AVCaptureDevice.Position = currentCamera?.position == .back ? .front : .back
        guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else {
            session.commitConfiguration()
            return
        }
        
        // add new input
        do {
            let input = try AVCaptureDeviceInput(device: newCamera)
            if session.canAddInput(input) {
                session.addInput(input)
                currentCamera = newCamera
            }
        } catch {
            self.error = .createCaptureInput
        }
        
        session.commitConfiguration()
    }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// photo capture delegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        // TODO: handle photo data
        if let imageData = photo.fileDataRepresentation() {
            print("Photo captured successfully, size: \(imageData.count) bytes")
            // save to photo library or process further
        }
    }
}
