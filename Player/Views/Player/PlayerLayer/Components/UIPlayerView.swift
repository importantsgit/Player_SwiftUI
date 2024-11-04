//
//  UIPlayerView.swift
//  Player
//
//  Created by 이재훈 on 10/18/24.
//

import AVFoundation
import UIKit
import AVKit
import MediaPlayer

/*
 pip모드 변환
 해상도 변환
 */

final class UIPlayerView: UIView {
    var currentPlayerState: PlayerViewModel.PlayerState
    
    var player: AVPlayer? = nil {
        didSet {
            if currentPlayerState.mode == .pipMode {
                playerLayer.player = player
            }
        }
    }
    
    // 지정한 AVPlayerLayer
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
        
    // 기본 CALayer 대신 이 특정 layer 클래스를 지정
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var pipController: AVPictureInPictureController?
    
    init(playerState: PlayerViewModel.PlayerState){
        self.currentPlayerState = playerState
        super.init(frame: UIApplication.currentWindow?.frame ?? .zero)
        
        setupMode(currentPlayerState.mode)
        playerLayer.videoGravity = currentPlayerState.gravity.value
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateState(_ newState: PlayerViewModel.PlayerState) {
        if currentPlayerState.mode != newState.mode {
            print("Player Mode Changed: \(currentPlayerState.mode) => \(newState.mode)")
            setupMode(newState.mode)
        }
        
        if currentPlayerState.gravity != newState.gravity {
            print("Player videoGravity Changed: \(currentPlayerState.gravity) => \(newState.gravity)")
            playerLayer.videoGravity = newState.gravity.value
        }
        
        currentPlayerState = newState
    }
}

private extension UIPlayerView {
    func setupMode(_ mode: PlayerMode) {
        switch mode {
        case .pipMode:
            enablePip()
        case .audioMode:
            disablePip()
        }
        
        // playerLayer.player = mode == .audioMode ? nil : player
    }
    
    func enablePip() {
        if AVPictureInPictureController.isPictureInPictureSupported()
            && pipController == nil {
            pipController = AVPictureInPictureController(playerLayer: playerLayer)
            pipController?.canStartPictureInPictureAutomaticallyFromInline = true
        }
    }
    
    func disablePip() {
        self.pipController = nil
    }
}
