//
//  ShowMediaController.swift
//  CameraApp
//
//  Created by Han Capital on 12/14/19.
//  Copyright © 2019 sapa.tech. All rights reserved.
//

import UIKit
import AVFoundation

class ShowMediaController: UIViewController {
    
    // MARK:- Variables -
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var url: URL? {
        didSet {
            playButton.isHidden = false
        }
    }
    
    // MARK:- Outlets -
    
    let photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play", for: .normal)
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK:- Action Methods -
    
    @objc private func handlePlay() {
        if let url = url {
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            playerLayer?.frame = view.frame
            view.layer.insertSublayer(playerLayer!, at: 2)
            player?.play()
            playButton.isHidden = true
        }
    }
    
    private func setupConstraints() {
        view.addSubview(photoView)
        photoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        photoView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        photoView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        photoView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        view.addSubview(playButton)
        playButton.centerYAnchor.constraint(equalTo: photoView.centerYAnchor).isActive = true
        playButton.centerXAnchor.constraint(equalTo: photoView.centerXAnchor).isActive = true
    }
    
    // MARK:- View Life Cycle Methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Show capture media"
        view.backgroundColor = .white
        setupConstraints()
    }
    
}
