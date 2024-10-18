//
//  OtherControllerView.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
//

import SwiftUI

struct OtherControllerView: View {
    enum ControllerViewAction {
        case buttonTapped
    }
    @EnvironmentObject var playerDataModel: PlayerDataModel
    
    @Binding var displayControllerCount: Int
    let title: String
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(title) {
                    handleAction(.buttonTapped)
                }
                .foregroundStyle(.white)
                .padding()
                Spacer()
            }
            Spacer()
        }
        .background(.black.opacity(0.3))
    }
    
    func handleAction(_ action: ControllerViewAction) {
        switch action {
        case .buttonTapped:
            playerDataModel.state.mode = [.audioMode, .pipMode].randomElement()!
            playerDataModel.state.speed = [.fast, .normal, .slow].randomElement()!
            playerDataModel.state.videoQuality = [.high, .low, .medium].randomElement()!
            playerDataModel.state.gravity = [.fill, .fit, .stretch].randomElement()!
        }
        
        displayControllerCount = 0
    }
    
}
