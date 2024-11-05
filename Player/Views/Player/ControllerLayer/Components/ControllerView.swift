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
        case settingButtonTapped
        case audioButtonTapped
        case backwardButtonTapped
        case playButtonTapped
        case forwardButtonTapped
    }
    
    @EnvironmentObject var playerManager: PlayerManager
    @State private var viewSize: CGSize = .zero
    @Binding var currentOrientation: UIInterfaceOrientation
    
    var body: some View {
        let isLandscape: Bool = currentOrientation.isLandscape
        let dragGesture = DragGesture(minimumDistance: 0)
            .onChanged { state in
                
                guard isLandscape && playerManager.controllerDisplayState == .normal && playerManager.containerDisplayState == .normal
                else { return }

                guard let currentWindowSize = UIApplication.currentWindowSize,
                      (currentWindowSize.minY + 40)...(currentWindowSize.maxY - 40) ~= state.startLocation.y
                else { return }

                let changeValue = state.translation.width
                let value = state.velocity
                
                print(changeValue, value)
                
                
            }
            .onEnded { state in
                guard isLandscape else { return }
                
            }
        
        HStack(spacing: 0) {
            Spacer()
                .frame(width: isLandscape ? 72 : 16)
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: isLandscape ? 72 : 16)
                HStack(spacing: 16) {
                    let imageSize: CGFloat = isLandscape ? 48 : 32
                    let size: CGFloat = isLandscape ? 24 : 16
                    
                    Spacer()
                    
                    Button {
                        handleAction(.audioButtonTapped)
                    } label: {
                        Image(systemName: "headphones")
                            .styled(size: size, tintColor: .white)
                            .frame(width: imageSize, height: imageSize)
                    }
                    
                    Button {
                        handleAction(.lockButtonTapped)
                    } label: {
                        Image(systemName: "lock.fill")
                            .styled(size: size, tintColor: .white)
                            .frame(width: imageSize, height: imageSize)
                    }
                    
                    if isLandscape {
                        Button {
                            handleAction(.settingButtonTapped)
                        } label: {
                            Image(systemName: "gearshape")
                                .styled(size: size, tintColor: .white)
                                .frame(width: imageSize, height: imageSize)
                        }
                    }
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
                HStack(spacing: 8) {
                    GeometryReader { geomerty in
                        VStack {
                            Spacer()
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.white.opacity(0.5))
                                    .clipShape(.capsule)
                                Rectangle()
                                    .fill(Color.white)
                                    .clipShape(.capsule)
                                    .frame(width: geomerty.size.width * playerManager.progressRatio)
                            }
                            .frame(width: geomerty.size.width, height: 4)
                        }
                    }
                    .frame(height: 32)
                    // TODO: 제스처 달기
                    .gesture(dragGesture)
                    
                    Button {
                        
                    } label: {
                        let imageSize: CGFloat = isLandscape ? 48 : 32
                        let size: CGFloat = isLandscape ? 24 : 16
                        
                        Image(systemName: "circle.square")
                            .styled(size: size, tintColor: .white)
                            .frame(width: imageSize, height: imageSize)
                    }
                }
                Spacer()
                
                Spacer()
                    .frame(height: isLandscape ? 72 : 16)
            }
            
            Spacer()
                .frame(width: isLandscape ? 72 : 16)
        }
        .onReadSize { viewSize = $0 }
        
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
            
        case .settingButtonTapped:
            playerManager.handleAction(.settingButtonTapped)
        }
    }
}
