//
//  PlayerDataModel.swift
//  Player
//
//  Created by Importants on 10/18/24.
//

import AVFoundation
import SwiftUI

final class PlayerDataModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var state: AVPlayerView.PlayerState
    
    init(url: URL?, state: AVPlayerView.PlayerState = .init()) {
        self.state = state
        self.player = url != nil ? AVPlayer(url: url!) : nil
    }
}
