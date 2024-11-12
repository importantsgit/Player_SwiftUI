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
        case seekingBarDragging(CGFloat)
        case seekingBarDragged
        case gestureConflicted
    }
    
    @EnvironmentObject var playerManager: PlayerManager
    @GestureState var seekGesture: Bool = true
    @Binding var currentOrientation: UIInterfaceOrientation
    
    var body: some View {
        let isLandscape: Bool = currentOrientation.isLandscape
        
        HStack(spacing: 0) {
            Spacer()
                .frame(width: isLandscape ? (currentOrientation == .landscapeLeft ? 24 : UIApplication.safeAreaInset?.left) : 16)
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: isLandscape ? UIApplication.safeAreaInset?.top : 16)
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
                    GeometryReader { geometry in
                        VStack(spacing: 0) {
                            /*
                             Spacer / Color.clear 자체는 터치 이벤트를 받을 수 없음
                             따라서 .contentShape(Rectangle())를 이용하여 터치 이벤트를 받아야 함
                            */
                            Color.clear
                                .contentShape(Rectangle())
                            HStack(spacing: 0) {
                                Color.clear
                                    .contentShape(Rectangle())
                                Text("\(playerManager.playingTime):\(playerManager.player?.currentItem?.duration.convertCMTimeToString() ?? "")")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.white.opacity(0.5))
                                    .clipShape(.capsule)
                                Rectangle()
                                    .fill(Color.white)
                                    .clipShape(.capsule)
                                    .frame(width: geometry.size.width * playerManager.progressRatio)
                            }
                            .frame(width: geometry.size.width, height: 4)
                            Color.clear
                                .contentShape(Rectangle())
                        }
                        .allowsHitTesting(true)
                        .onChange(of: seekGesture) { (_, seekGesture) in
                            if seekGesture == true {
                                handleAction(.gestureConflicted)
                            }
                        }
                        .gesture(
                            // 내부 width 값을 알아야하기 때문에 Gesture 내부에 배치
                            // 참고로 각가의 파라미터 초기값은 10 / .local임
                            DragGesture(minimumDistance: 0)
                                .updating($seekGesture) { currentState, state, transition in
                                    print("updating")
                                     state = currentState.translation == .zero ? true : false
                                 }
                                .onChanged { state in
                                    Task {
                                        guard let safeAreaInset = UIApplication.safeAreaInset,
                                              let currentWindowSize = UIApplication.currentWindowSize
                                        else { return }
                                        
                                        print("\(safeAreaInset.top)...\(currentWindowSize.maxY) - \(safeAreaInset.bottom) ~= \(state.startLocation.y)")
                                        
                                        if isLandscape {
                                            guard (safeAreaInset.top)...(currentWindowSize.maxY - safeAreaInset.bottom) ~= state.startLocation.y
                                            else { return }
                                        }

                                        let seekingBarWidth = geometry.size.width
                                        let changeValue = max(0, min(seekingBarWidth, state.location.x))
                                        let updatePosition = changeValue == 0 ? 0 : changeValue / seekingBarWidth
                                        handleAction(.seekingBarDragging(updatePosition))
                                    }

                                }
                                .onEnded { state in
                                    handleAction(.seekingBarDragged)
                                }
                        )
                    }
                    .frame(height: 32)
                    
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
                    .frame(height: isLandscape ? (UIApplication.safeAreaInset?.bottom ?? 0) + 10 : 16)
            }
            Spacer()
                .frame(width: isLandscape ? (currentOrientation == .landscapeLeft ? UIApplication.safeAreaInset?.left : 24) : 16)
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
            
        case .settingButtonTapped:
            playerManager.handleAction(.settingButtonTapped)
            
        case let .seekingBarDragging(updatePosition):
            playerManager.handleAction(.seekingBarDragging(updatePosition))
            
        case .seekingBarDragged:
            playerManager.handleAction(.seekingBarDragged)
        
        case .gestureConflicted:
            playerManager.handleAction(.resetGestureValue)
        }
    }
}
