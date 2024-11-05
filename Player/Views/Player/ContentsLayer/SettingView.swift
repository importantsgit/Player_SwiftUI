//
//  SettingView.swift
//  Player
//
//  Created by Importants on 10/22/24.
//

import SwiftUI

struct SettingView: View {
    enum SettingViewAction {
        case cancelButtonTapped
    }
    
    @EnvironmentObject var playerManager: PlayerManager
    
    var body: some View {
        Text("Audio Mode View")
    }
    
    func handleAction(_ action: SettingViewAction) {
        switch action {
        case .cancelButtonTapped:
            playerManager.handleAction(<#T##action: PlayerManager.PlayerViewAction##PlayerManager.PlayerViewAction#>)
        }
    }
}
