//
//  ViewController.swift
//  CameraApp
//
//  Created by Han Capital on 12/14/19.
//  Copyright © 2019 sapa.tech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Outlets -
    
    private let addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add photo", for: .normal)
        button.addTarget(self, action: #selector(handleAddPhoto), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var alertController: UIAlertController = {
        let alert = UIAlertController(title: "Load photo", message: "For your accout", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            self.showCameraController()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        return alert
    }()
    
    // MARK: - Action Methods -
    
    @objc private func handleAddPhoto() {
        present(alertController, animated: true)
    }
    
    // MARK: - Custom Methods -
    
    private func showCameraController() {
        let cameraController = CameraController()
        navigationController?.pushViewController(cameraController, animated: true)
    }
    
    private func setupConstraints() {
        view.addSubview(addPhotoButton)
        addPhotoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        addPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    // MARK: - View Life Cycle Methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "CameraApp"
        view.backgroundColor = .white
        setupConstraints()
    }

}

