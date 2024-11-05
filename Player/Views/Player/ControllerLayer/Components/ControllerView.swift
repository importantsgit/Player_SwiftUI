//
//  ControllerView.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
//

import AVFoundation
import SwiftUI

struct ControllerView: View {
    enum ControllerViewAction {
        case lockButtonTapped
        case audioButtonTapped
        case backwardButtonTapped
        case playButtonTapped
        case forwardButtonTapped
        case speedButtonTapped
        case qualityButtonTapped
        case gravityButtonTapped
    }
    
    @EnvironmentObject var playerManager: PlayerManager
    @Binding var currentOrientation: UIInterfaceOrientation
    
    var body: some View {
        let isLandscape: Bool = currentOrientation.isLandscape
        HStack(spacing: 0) {
            Spacer()
                .frame(width: isLandscape ? 72 : 16)
            VStack {
                Spacer()
                    .frame(height: isLandscape ? 72 : 16)
                HStack {
                    Spacer()
                    
                    Button {
                        handleAction(.audioButtonTapped)
                    } label: {
                        let imageSize: CGFloat = isLandscape ? 48 : 32
                        let size: CGFloat = isLandscape ? 24 : 16
                        
                        Image(systemName: "headphones")
                            .styled(size: size, tintColor: .white)
                            .frame(width: imageSize, height: imageSize)
                    }
                    
                    Button {
                        handleAction(.lockButtonTapped)
                    } label: {
                        let imageSize: CGFloat = isLandscape ? 48 : 32
                        let size: CGFloat = isLandscape ? 24 : 16
                        
                        Image(systemName: "lock.fill")
                            .styled(size: size, tintColor: .white)
                            .frame(width: imageSize, height: imageSize)
                    }
                    
                    Spacer()
                        .frame(width: 16)
                }
                Spacer()
                HStack(spacing: 42) {
                    Button {
                        handleAction(.backwardButtonTapped)
                    } label: {
                        let imageSize: CGFloat = isLandscape ? 48 : 32
                        let size: CGFloat = isLandscape ? 24 : 16
                        
                        Image(systemName: "chevron.left.2")
                            .styled(size: size, tintColor: .white)
                            .frame(width: imageSize, height: imageSize)
                    }
                    
                    Button {
                        handleAction(.playButtonTapped)
                    } label: {
                        let imageSize: CGFloat = isLandscape ? 48 : 32
                        let size: CGFloat = isLandscape ? 24 : 16
                        
                        Image(
                            systemName: playerManager.playerTimeState == .playing ? "pause" : "play"
                        )
                        .styled(size: size, tintColor: .white)
                        .frame(width: imageSize, height: imageSize)
                    }
                    
                    Button {
                        handleAction(.forwardButtonTapped)
                    } label: {
                        let imageSize: CGFloat = isLandscape ? 48 : 32
                        let size: CGFloat = isLandscape ? 32 : 24
                        
                        Image(systemName: "chevron.right.2")
                            .styled(size: size, tintColor: .white)
                            .frame(width: imageSize, height: imageSize)
                    }
                }
                Spacer()
                HStack(spacing: 0) {
                    GeometryReader { geomerty in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.5))
                                .clipShape(.capsule)
                            Rectangle()
                                .fill(Color.white)
                                .clipShape(.capsule)
                                .frame(width: geomerty.size.width * playerManager.progressRatio)
                        }
                        .frame(width: geomerty.size.width)
                    }
                    .frame(height: 4)
                }
                Spacer()
                HStack(alignment: .center, spacing: 42) {
                    Button("속도") {
                        handleAction(.speedButtonTapped)
                    }
                    .frame(width: 100)
                    
                    Button("화질") {
                        handleAction(.qualityButtonTapped)
                    }
                    .frame(width: 100)
                    
                    Button("비율") {
                        handleAction(.gravityButtonTapped)
                    }
                    .frame(width: 100)
                }
                .foregroundStyle(.white)
                .hidden(isLandscape == false)
                
                Spacer()
                    .frame(height: isLandscape ? 72 : 16)
            }
            
            Spacer()
                .frame(width: isLandscape ? 72 : 16)
        }
        
    }
    
    func handleAction(_ action: ControllerViewAction) {
        switch action {
        case .lockButtonTapped:
            playerManager.handleAction(.lockButtonTapped)
            
        case .audioButtonTapped:
            playerManager.handleAction(.audioButtonTapped)
            
        case .forwardButtonTapped:
            playerManager.handleAction(.seekForward(10))
            
        case .playButtonTapped:
            playerManager.handleAction(.playButtonTapped)
            
        case .backwardButtonTapped:
            playerManager.handleAction(.seekBackward(10))
            
        case .speedButtonTapped:
            let speed: PlayerSpeed = [.fast, .normal, .slow].randomElement()!
            playerManager.handleAction(.speedButtonTapped(speed))
            
        case .qualityButtonTapped:
            let videoQuality: PlayerQualityPreset = [.high, .low, .medium].randomElement()!
            playerManager.handleAction(.qualityButtonTapped(videoQuality))
            
        case .gravityButtonTapped:
            let gravity: PlayerGravity = [.fill, .fit, .stretch].randomElement()!
            playerManager.handleAction(.gravityButtonTapped(gravity))
        }
    }
}
