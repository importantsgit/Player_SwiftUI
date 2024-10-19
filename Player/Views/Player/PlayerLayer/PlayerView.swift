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

enum PlayerTimeState {
    case playing
    case ended
    case pause
    case buffering
}

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
    @Binding var state: UIPlayerView.PlayerState
    
    func makeUIView(context: Context) -> UIPlayerView {
        let view = UIPlayerView(state: state)
        view.player = player
        view.pipController?.delegate = context.coordinator
        view.setupPip()
        view.setupRemoteCommands()
        view.setMode(.pipMode) // mode default => PIP
        
        return view
    }
    
    // 부모 뷰가 렌더링 된다면 해당 함수 호출
    // 관련된 상태 변수가 변했을 경우
    // 앱 생명주기 이벤트 발생 시
    func updateUIView(_ uiView: UIPlayerView, context: Context) {
        if uiView.player !== player {
            print("player is changed")
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
