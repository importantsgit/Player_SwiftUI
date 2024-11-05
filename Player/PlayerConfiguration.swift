//
//  PlayerConfiguration.swift
//  Player
//
//  Created by 이재훈 on 11/4/24.
//

import AVFoundation

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
enum PlayerQualityPreset: CaseIterable {
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
