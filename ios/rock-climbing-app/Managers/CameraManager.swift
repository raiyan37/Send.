//
//  CameraManager.swift
//  RockClimber
//
//  Created on 2026-01-17
//

import AVFoundation
import SwiftUI
import Combine
import UIKit

class CameraManager: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var error: CameraError?
    @Published var session = AVCaptureSession()
    @Published var capturedPhotoData: Data?
    @Published var capturedPhotoPreview: UIImage?
    
    private var videoOutput = AVCaptureMovieFileOutput()
    private var photoOutput = AVCapturePhotoOutput()
    private var currentCamera: AVCaptureDevice?
    
    enum CameraError: Error, LocalizedError {
        case unauthorized
        case cannotAddInput
        case cannotAddOutput
        case createCaptureInput
        case photoProcessingFailed
        
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
            case .photoProcessingFailed:
                return "Failed to process photo"
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
        settings.photoQualityPrioritization = .balanced
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    private func prepareUploadJpeg(from rawPhotoData: Data) -> Data? {
        guard let image = UIImage(data: rawPhotoData) else {
            return nil
        }

        let normalized = image.normalized()
        let resized = normalized.resizedToMaxWidth(1216)

        let maxBytes = 4 * 1024 * 1024
        var quality: CGFloat = 0.85
        var jpegData = resized.jpegData(compressionQuality: quality)

        while let data = jpegData, data.count > maxBytes, quality > 0.25 {
            quality -= 0.1
            jpegData = resized.jpegData(compressionQuality: quality)
        }

        guard let data = jpegData, data.count <= maxBytes else {
            return nil
        }

        return data
    }
}

// photo capture delegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let preparedJpegData = prepareUploadJpeg(from: imageData),
              let previewImage = UIImage(data: preparedJpegData) else {
            DispatchQueue.main.async { [weak self] in
                self?.error = .photoProcessingFailed
            }
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.capturedPhotoPreview = previewImage
            self?.capturedPhotoData = preparedJpegData
        }
    }
}

private extension UIImage {
    func normalized() -> UIImage {
        if imageOrientation == .up {
            return self
        }

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func resizedToMaxWidth(_ maxWidth: CGFloat) -> UIImage {
        guard size.width > 0 else { return self }

        let scale = min(1, maxWidth / size.width)
        if scale == 1 {
            return self
        }

        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
