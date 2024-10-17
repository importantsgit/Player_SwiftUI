//
//  PlayerView.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
//

import AVFoundation
import AVKit
import MediaPlayer
import SwiftUI

enum PlayerSpeed: CaseIterable {
    case fast
    case normal
    case slow
    
    var value: Float {
        switch self {
        case .fast: return 1.5
        case .normal: return 1.0
        case .slow: return 0.5
        }
    }
}

enum PlayerMode {
    case audioMode
    case pipMode
}

// 품질 프리셋 설정
enum PlayerQualityPreset {
    case low, medium, high
    
    // 높은 해상도는 일반적으로 더 높은 비트레이트가 필요
    // 낮은 해상도는 높은 비트레이트가 필요 없음
    
    // 초당 처리되는 데이터 양
    var bitrate: Double {
        switch self {
        case .low: return 1_000_000 // 1 Mbps
        case .medium: return 2_500_000 // 2.5 Mbps
        case .high: return 5_000_000 // 5 Mbps
        }
    }
    
    // 프레임의 픽셀 수
    var resolution: CGSize {
        switch self {
        case .low: return CGSize(width: 640, height: 360) // 360p
        case .medium: return CGSize(width: 1280, height: 720) // 720p
        case .high: return CGSize(width: 1920, height: 1080) // 1080p
        }
    }
}

enum PlayerGravity: String, CaseIterable {
    case fit = "Fit"
    case fill = "Fill"
    case stretch = "Stretch"
    
    var value: AVLayerVideoGravity {
        switch self {
        case .fit: return .resizeAspect
        case .fill: return .resizeAspectFill
        case .stretch: return .resize
        }
    }
}

struct PlayerView: UIViewRepresentable {
    @Binding var player: AVPlayer?
    @Binding var state: AVPlayerView.PlayerState
    
    func makeUIView(context: Context) -> AVPlayerView {
        let view = AVPlayerView(state: state)
        view.player = player
        view.pipController?.delegate = context.coordinator
        view.setupPip()
        view.setupRemoteCommands()
        
        return view
    }
    
    // 부모 뷰가 렌더링 된다면 해당 함수 호출
    // 관련된 상태 변수가 변했을 경우
    // 앱 생명주기 이벤트 발생 시
    func updateUIView(_ uiView: AVPlayerView, context: Context) {
        if uiView.player !== player {
            uiView.player = player
        }
        // State Update
        uiView.updateState(state)
    }
    
    // UIKit의 Delegate Pattern을 SwiftUI에서 사용할 수 있게 해주는 브릿지 역할
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, AVPictureInPictureControllerDelegate {
        var parent: PlayerView
        
        init(parent: PlayerView) {
            self.parent = parent
        }
        
        func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
            print("pictureInPictureControllerWillStartPictureInPicture")
        }
    }
}

// 그래픽 빨리 감기
final class AVPlayerView: UIView {
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
        super.init(frame: .zero)
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
            toggleMode(newState.mode)
        }
        
        if state.gravity != newState.gravity {
            playerLayer.videoGravity = newState.gravity.value
        }
        
        if state.speed != newState.speed {
            player?.rate = newState.speed.value
        }
        
        if state.videoQuality != newState.videoQuality {
            player?.currentItem?.preferredMaximumResolution = state.videoQuality.resolution
            player?.currentItem?.preferredPeakBitRate = state.videoQuality.bitrate
        }
    }
}

private extension AVPlayerView {
    func toggleMode(_ mode: PlayerMode) {
        switch mode {
        case .audioMode:
            disablePip()
            enableAudioMode()
        case .pipMode:
            enablePip()
            disableAudioMode()
        }
    }
    
    func disablePip() {
        pipController?.stopPictureInPicture()
    }
    
    func enablePip() {
        pipController?.startPictureInPicture()
    }
    
    func enableAudioMode() {
        playerLayer.player = nil
        setupAudioSession()
        remoteCommandCenter.playCommand.isEnabled = true
        remoteCommandCenter.pauseCommand.isEnabled = true
    }
    
    func disableAudioMode() {
        playerLayer.player = player
        remoteCommandCenter.playCommand.isEnabled = false
        remoteCommandCenter.pauseCommand.isEnabled = false
    }
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch {
            print("error: \(error.localizedDescription)")
        }
    }
}
