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
        case speedButtonTapped(PlayerSpeed)
        case qualityButtonTapped(PlayerQualityPreset)
        case gravityButtonTapped(PlayerGravity)
    }
    
    @EnvironmentObject var playerManager: PlayerManager
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: 16)
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        handleAction(.cancelButtonTapped)
                    } label: {
                        let imageSize: CGFloat = 48
                        let size: CGFloat = 24
                        
                        Image(systemName: "xmark")
                            .styled(size: size, tintColor: .white)
                            .frame(width: imageSize, height: imageSize)
                    }
                }
                
                List {
                    Group {
                        Button("Speed") {
                            handleAction(.speedButtonTapped(.allCases.randomElement()!))
                        }
                        
                        Button("Quality") {
                            handleAction(.qualityButtonTapped(.allCases.randomElement()!))
                        }
                        
                        Button("Gravity") {
                            handleAction(.gravityButtonTapped(.allCases.randomElement()!))
                        }
                    }
                    .listRowBackground(Color.clear)
                    .tint(.black)

                }
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
            }
            
            Spacer()
                .frame(width: 16)
        }
        .background(Color.gray)

    }
    
    func handleAction(_ action: SettingViewAction) {
        switch action {
        case .cancelButtonTapped:
            playerManager.handleAction(.closeContentButtonTapped)
            
        case let .speedButtonTapped(speed):
            playerManager.handleAction(.speedButtonTapped(speed))
            
        case let .qualityButtonTapped(quality):
            playerManager.handleAction(.qualityButtonTapped(quality))
            
        case let .gravityButtonTapped(gravity):
            playerManager.handleAction(.gravityButtonTapped(gravity))
        }
    }
}
