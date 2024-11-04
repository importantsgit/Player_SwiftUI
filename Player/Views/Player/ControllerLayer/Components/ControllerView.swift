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
    
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @Binding var controllerDisplayState: ControllerContainerView.ControllerDisplayState
    @Binding var currentOrientation: UIInterfaceOrientation
    
    var body: some View {
        let isLandscape: Bool = currentOrientation.isLandscape
        VStack {
            Spacer()
                .frame(height: 24)
            HStack {
                Spacer()
                    .frame(height: isLandscape ? 72 : 16)
                
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
                        systemName: playerViewModel.playerTimeState == .playing ? "pause" : "play"
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
                            .frame(width: geomerty.size.width * playerViewModel.progressRatio)
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
    }
    
    func handleAction(_ action: ControllerViewAction) {
        switch action {
        case .lockButtonTapped:
            controllerDisplayState = .lock
            
        case .audioButtonTapped:
            playerViewModel.handleAction(.audioButtonTapped)
            controllerDisplayState = .audio
            
        case .forwardButtonTapped:
            playerViewModel.handleAction(.seekForward(10))
            
        case .playButtonTapped:
            playerViewModel.handleAction(.playButtonTapped)
            
        case .backwardButtonTapped:
            playerViewModel.handleAction(.seekBackward(10))
            
        case .speedButtonTapped:
            let speed: PlayerSpeed = [.fast, .normal, .slow].randomElement()!
            playerViewModel.handleAction(.speedButtonTapped(speed))
            
        case .qualityButtonTapped:
            let videoQuality: PlayerQualityPreset = [.high, .low, .medium].randomElement()!
            playerViewModel.handleAction(.qualityButtonTapped(videoQuality))
            
        case .gravityButtonTapped:
            let gravity: PlayerGravity = [.fill, .fit, .stretch].randomElement()!
            playerViewModel.handleAction(.gravityButtonTapped(gravity))
        }
        
        playerViewModel.showControllerSubject.send(true)
    }
}
