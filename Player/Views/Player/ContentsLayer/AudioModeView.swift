//
//  AudioModeView.swift
//  Player
//
//  Created by Importants on 10/24/24.
//

import SwiftUI

struct AudioModeView: View {
    enum AudioModeViewAction {
        case deactivateAudioButtonTapped
        case playButtonTapped
    }
    @EnvironmentObject var playerDataModel: PlayerDataModel
    @Binding var controllerDisplayState: ControllerContainerView.ControllerDisplayState
    @Binding var currentOrientation: UIInterfaceOrientation
    
    var body: some View {
        let isLandscape: Bool = currentOrientation.isLandscape
        VStack {
            Spacer()
                .frame(height: 24)
            HStack {
                Spacer()
                
                Button {
                    handleAction(.deactivateAudioButtonTapped)
                } label: {
                    Image(systemName: "video")
                        .styled(size: 24, tintColor: .white)
                        .frame(width: 48, height: 48)
                }
                
                Spacer()
                    .frame(width: 16)
            }
            Spacer()
            
            HStack {
                Button {
                    handleAction(.playButtonTapped)
                } label: {
                    let imageSize: CGFloat = isLandscape ? 48 : 32
                    let size: CGFloat = isLandscape ? 24 : 16
                    
                    Image(
                        systemName: playerDataModel.playerTimeState == .playing ? "pause" : "play"
                    )
                    .styled(size: size, tintColor: .white)
                    .frame(width: imageSize, height: imageSize)
                }
            }
            
            Spacer()
        }
        //.background(.black)
    }
    
    func handleAction(_ action: AudioModeViewAction) {
        switch action {
        case .deactivateAudioButtonTapped:
            playerDataModel.state.mode = .pipMode
            controllerDisplayState = .main(.normal)
            playerDataModel.showControllerSubject.send(true)
            
        case .playButtonTapped:
            if playerDataModel.isCurrentItemFinished {
                playerDataModel.player?.seek(to: .zero)
                return
            }
            
            playerDataModel.playerTimeState == .playing ?
            playerDataModel.player?.pause() :
            playerDataModel.player?.play()
        }
    }
}
