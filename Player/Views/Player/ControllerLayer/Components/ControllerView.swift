//
//  ControllerView.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
//

import SwiftUI

struct ControllerView: View {
    enum ControllerViewAction {
        case rewindButtonTapped
        case playButtonTapped
        case forwardButtonTapped
    }
    @EnvironmentObject var playerDataModel: PlayerDataModel
    @Binding var isLockController: Bool
    @Binding var controllerDisplayState: ControllerContainerView.ControllerDisplayState
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 24)
            HStack {
                Spacer()
                Button {
                    isLockController = true
                } label: {
                    Image(systemName: "lock.fill")
                        .frame(width: 48, height: 48)
                }

                Spacer()
                    .frame(width: 16)
            }
            Spacer()
            HStack(spacing: 42) {
                Button {
                    handleAction(.rewindButtonTapped)
                } label: {
                    Image(systemName: "chevron.left.2")
                        .frame(
                            width: 100,
                            height: 48
                        )
                }
                
                Button {
                    handleAction(.playButtonTapped)
                } label: {
                    Image(systemName: playerDataModel.playerTimeState == .playing ? "pause" : "play")
                        .frame(
                            width: 100,
                            height: 48
                        )
                }
                
                Button {
                    handleAction(.forwardButtonTapped)
                } label: {
                    Image(systemName: "chevron.right.2")
                        .frame(
                            width: 100,
                            height: 48
                        )
                }
            }
            Spacer()
                .frame(height: 24)
        }
    }
    
    func handleAction(_ action: ControllerViewAction) {
        switch action {
        case .forwardButtonTapped:
            controllerDisplayState = .main(.other)
            
        case .playButtonTapped:
            if playerDataModel.isCurrentItemFinished {
                playerDataModel.player?.seek(to: .zero)
                return
            }
            
            playerDataModel.playerTimeState == .playing ?
            playerDataModel.player?.pause() :
            playerDataModel.player?.play()
            
        case .rewindButtonTapped:
            controllerDisplayState = .main(.other)
        }
        
        playerDataModel.showControllerSubject.send(true)
    }
}
