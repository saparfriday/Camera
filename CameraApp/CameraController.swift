//
//  CameraController.swift
//  CameraApp
//
//  Created by Han Capital on 12/14/19.
//  Copyright © 2019 sapa.tech. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    
    // MARK:- Variables -
    
    private let captureSession = AVCaptureSession()
    private let photoFileOutput = AVCapturePhotoOutput()
    private let movieFileOutput = AVCaptureMovieFileOutput()
    
    // MARK:- Outlets -
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "dismiss"), for: .normal)
        button.addTarget(self, action: #selector(handleDismissButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "capturePhoto"), for: .normal)
        button.addTarget(self, action: #selector(captureButtonDidTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    private let switchCameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "switch"), for: .normal)
        button.addTarget(self, action: #selector(handleSwitchCamera), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK:- Action Methods -
    
    @objc private func handleDismissButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func captureButtonDidTapped() {
        let settings = AVCapturePhotoSettings()
        self.photoFileOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc private func handleSwitchCamera() {
        captureSession.beginConfiguration()
        
        // Create new video device input. If current front = create back etc.
        let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput
        let newCameraDevice = currentInput?.device.position == .back ? getDevice(position: .front) : getDevice(position: .back)
        let newVideoInput = try? AVCaptureDeviceInput(device: newCameraDevice!)
        
        // Create new audio device input
        let captureAudio = AVCaptureDevice.default(for: AVMediaType.audio)
        let inputAudio = try? AVCaptureDeviceInput(device: captureAudio!)
        
        // Remove all current inputs
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
        
        // Add new created inputs
        if captureSession.inputs.isEmpty {
            captureSession.addInput(newVideoInput!)
            captureSession.addInput(inputAudio!)
        }
        captureSession.commitConfiguration()
    }
    
    @objc private func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            // Long progress start
            captureButton.setImage(UIImage(named: "captureVideo"), for: .normal)
            // Switch photo to video
            captureSession.removeOutput(photoFileOutput)
            captureSession.addOutput(movieFileOutput)
            // Create video file
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
            let filePath = documentsURL.appendingPathComponent("tempMovie.mp4")
            if FileManager.default.fileExists(atPath: filePath.absoluteString) {
                do {
                    try FileManager.default.removeItem(at: filePath)
                }
                catch {
                    // exception while deleting old cached file
                    // ignore error if any
                }
            }
            movieFileOutput.startRecording(to: filePath, recordingDelegate: self)
        } else if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            // Long press end. Switch video to photo
            captureButton.setImage(UIImage(named: "capturePhoto"), for: .normal)
            captureSession.removeOutput(movieFileOutput)
            captureSession.addOutput(photoFileOutput)
            movieFileOutput.stopRecording()
        }
    }
    
    // MARK:- View Life Cycle Methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupConstraints()
        
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        captureButton.addGestureRecognizer(longPressGesture);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK:- Custom Methods -
    
    func setupCaptureSession() {
        
        //1. Setup inputs
        guard let captureVideoDevice = AVCaptureDevice.default(for: AVMediaType.video),
        let captureAudioDevice = AVCaptureDevice.default(for: AVMediaType.audio) else { return }
        do {
            let inputVideo = try AVCaptureDeviceInput(device: captureVideoDevice)
            let inputAudio = try AVCaptureDeviceInput(device: captureAudioDevice)
            if captureSession.canAddInput(inputVideo) {
                captureSession.addInput(inputVideo)
            }
            if captureSession.canAddInput(inputAudio) {
                captureSession.addInput(inputAudio)
            }
        } catch let err {
            print("Could not setup camera input:", err)
        }

        //2. Setup outputs
        if captureSession.canAddOutput(photoFileOutput){
            captureSession.addOutput(photoFileOutput)
        }

        //3. Setup output preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
        
    }

    // Did finish photo capture
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let previewImage = UIImage(data: photo.fileDataRepresentation()!){
            let showMediaController = ShowMediaController()
            showMediaController.photoView.image = previewImage
            navigationController?.pushViewController(showMediaController, animated: true)
        }
    }
    
    // Did finish video recording
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        let showMediaController = ShowMediaController()
        showMediaController.url = outputFileURL
        navigationController?.pushViewController(showMediaController, animated: true)
    }
    
    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devices() as NSArray
        for de in devices {
            let deviceConverted = de as! AVCaptureDevice
            if(deviceConverted.position == position){
               return deviceConverted
            }
        }
       return nil
    }
    
    func setupConstraints() {
        view.addSubview(dismissButton)
        dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        view.addSubview(captureButton)
        captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34).isActive = true
        captureButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        captureButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        view.addSubview(switchCameraButton)
        switchCameraButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor).isActive = true
        switchCameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50).isActive = true
        switchCameraButton.widthAnchor.constraint(equalToConstant: 28).isActive = true
        switchCameraButton.heightAnchor.constraint(equalToConstant: 38).isActive = true
    }
    
}
