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
            pipController?.requiresLinearPlayback = true
        }
    }
    
    func setupRemoteCommands() {
        let center = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = center.nowPlayingInfo ?? [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = "콘텐츠 제목"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "콘텐츠 아티스트"
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        MPRemoteCommandCenter.shared().playCommand.addTarget { [weak self] _ in
            self?.player?.play()
            return .success
        }
        
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { [weak self] _ in
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
        
        state = newState
    }
    
    func setMode(_ mode: PlayerMode) {
        // nil 처리해줘야지 백그라운드에서 오디오 모드 재생 가능
        playerLayer.player = mode == .audioMode ? nil : player
        
        switch mode {
        case .audioMode:
            enableAudioMode()
            disablePip()
        case .pipMode:
            disableAudioMode()
            enablePip()
        }
    }
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch {
            print("error: \(error.localizedDescription)")
        }
    }
    
    deinit {
        self.disableAudioMode()
        self.disablePip()
    }
}

private extension UIPlayerView {
    func disablePip() {
        self.pipController = nil
    }
    
    func enablePip() {
        if AVPictureInPictureController.isPictureInPictureSupported()
            && pipController == nil {
            pipController = AVPictureInPictureController(playerLayer: playerLayer)
            pipController?.canStartPictureInPictureAutomaticallyFromInline = true
        }
    }
    
    func enableAudioMode() {
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        // UIApplication.shared.beginReceivingRemoteControlEvents() // 공유된 객체를 사용할 때는 호출할 필요 없음
    }
    
    func disableAudioMode() {
        playerLayer.isHidden = false
        
        MPRemoteCommandCenter.shared().playCommand.isEnabled = false
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = false
        // UIApplication.shared.endReceivingRemoteControlEvents() // 공유된 객체를 사용할 때는 호출할 필요 없음
    }
}
