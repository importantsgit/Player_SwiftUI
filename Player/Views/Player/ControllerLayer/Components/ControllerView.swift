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
    @Binding var displayControllerCount: Int
    @Binding var controllerState: ControllerContainerView.ControllerState
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("ControllerView")
                    .foregroundStyle(.white)
                Spacer()
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
        }
        .background(.black.opacity(0.3))
    }
    
    func handleAction(_ action: ControllerViewAction) {
        switch action {
        case .forwardButtonTapped:
            controllerState.showTwoControllerView()
            
        case .playButtonTapped:
            if playerDataModel.isCurrentItemFinished {
                playerDataModel.player?.seek(to: .zero)
                return
            }
            
            playerDataModel.playerTimeState == .playing ?
            playerDataModel.player?.pause() :
            playerDataModel.player?.play()
            
        case .rewindButtonTapped:
            controllerState.showOneControllerView()
        }
        
        displayControllerCount = 0
    }
}
