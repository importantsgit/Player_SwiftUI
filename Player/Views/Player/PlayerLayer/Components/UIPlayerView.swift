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

final class UIPlayerView: UIView {
    struct PlayerState {
        var mode: PlayerMode
        var videoQuality: PlayerQualityPreset
        var speed: PlayerSpeed
        var gravity: PlayerGravity
        
        init(
            mode: PlayerMode = .pipMode,
            videoQuality: PlayerQualityPreset = .medium,
            speed: PlayerSpeed = .normal,
            gravity: PlayerGravity = .fit
        ) {
            self.mode = mode
            self.videoQuality = videoQuality
            self.speed = speed
            self.gravity = gravity
        }
    }
    
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    // 지정한 AVPlayerLayer
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var state: PlayerState
    
    // 기본 CALayer 대신 이 특정 layer 클래스를 지정
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var pipController: AVPictureInPictureController?
    private let remoteCommandCenter = MPRemoteCommandCenter.shared()
    
    init(state: PlayerState){
        self.state = state
        super.init(frame: UIApplication.currentWindow?.frame ?? .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPip() {
        if AVPictureInPictureController.isPictureInPictureSupported() {
            pipController = AVPictureInPictureController(playerLayer: playerLayer)
        }
    }
    
    func setupRemoteCommands() {
        remoteCommandCenter.playCommand.addTarget { [weak self] _ in
            self?.player?.play()
            return .success
        }
        
        remoteCommandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.player?.pause()
            return .success
        }
    }
    
    func updateState(_ newState: PlayerState) {
        if state.mode != newState.mode {
            print("Player Mode Changed: \(state.mode) => \(newState.mode)")
            setMode(newState.mode)
        }
        
        if state.gravity != newState.gravity {
            print("Player videoGravity Changed: \(state.gravity) => \(newState.gravity)")
            playerLayer.videoGravity = newState.gravity.value
        }
        
        if state.speed != newState.speed {
            print("Player speed Changed: \(state.speed) => \(newState.speed)")
            player?.rate = newState.speed.value
        }
        
        if state.videoQuality != newState.videoQuality {
            print("Player videoQuality is Changed: \(state.videoQuality.bitrate), \(state.videoQuality.resolution) => \(newState.videoQuality.bitrate), \(newState.videoQuality.resolution)")
            player?.currentItem?.preferredMaximumResolution = newState.videoQuality.resolution
            player?.currentItem?.preferredPeakBitRate = newState.videoQuality.bitrate
        }
    }
    
    func setMode(_ mode: PlayerMode) {
        setupAudioSession(mode: mode)
        switch mode {
        case .audioMode:
            disablePip()
            enableAudioMode()
        case .pipMode:
            enablePip()
            disableAudioMode()
        }
    }
}

private extension UIPlayerView {
    func disablePip() {
        pipController?.stopPictureInPicture()
    }
    
    func enablePip() {
        pipController?.startPictureInPicture()
    }
    
    func enableAudioMode() {
        playerLayer.player = nil
        remoteCommandCenter.playCommand.isEnabled = true
        remoteCommandCenter.pauseCommand.isEnabled = true
    }
    
    func disableAudioMode() {
        playerLayer.player = player
        remoteCommandCenter.playCommand.isEnabled = false
        remoteCommandCenter.pauseCommand.isEnabled = false
    }
    
    func setupAudioSession(mode: PlayerMode) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: mode == .pipMode ? .moviePlayback : .default)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch {
            print("error: \(error.localizedDescription)")
        }
    }
}
