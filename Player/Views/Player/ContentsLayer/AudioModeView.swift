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
    }
    @EnvironmentObject var playerDataModel: PlayerDataModel
    @Binding var controllerDisplayState: ControllerContainerView.ControllerDisplayState
    
    var body: some View {
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
        }
        .background(.black)
    }
    
    func handleAction(_ action: AudioModeViewAction) {
        switch action {
        case .deactivateAudioButtonTapped:
            playerDataModel.state.mode = .pipMode
            controllerDisplayState = .main(.normal)
            playerDataModel.showControllerSubject.send(true)
        }
    }
}
