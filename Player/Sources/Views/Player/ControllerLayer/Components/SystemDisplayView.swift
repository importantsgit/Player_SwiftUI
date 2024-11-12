//
//  SystemDisplayView.swift
//  Player
//
//  Created by Importants on 10/20/24.
//

import SwiftUI

struct SystemDisplayView: View {
    @State private var isShowBrightnessBar: Bool = false
    @State private var isShowVolumeBar: Bool = false
    @EnvironmentObject var systemDataModel: SystemDataModel
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                if isShowBrightnessBar {
                    Spacer()
                        .frame(width: 64)
                    
                    VStack(spacing: 10) {
                        Image(systemName: "lightbulb.max.fill")
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                        
                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .fill(Color.white.opacity(0.5))
                                .clipShape(.capsule)
                            Rectangle()
                                .fill(Color.white)
                                .clipShape(.capsule)
                                .frame(height: 132 * CGFloat(systemDataModel.brightnessValue.changed))
                        }
                    }
                    .frame(width: 6, height: 166)
                }

                Spacer()
                
                if isShowVolumeBar {
                    VStack(spacing: 10) {
                        Image(systemName: systemDataModel.volumeValue.changed >= 0 ? "speaker.wave.3.fill" : "speaker.fill")
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                        
                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .fill(Color.white.opacity(0.5))
                                .clipShape(.capsule)
                            Rectangle()
                                .fill(Color.white)
                                .clipShape(.capsule)
                                .frame(height: 132 * CGFloat(systemDataModel.volumeValue.changed))
                        }
                    }
                    .frame(width: 6, height: 166)
                    
                    Spacer()
                        .frame(width: 32)
                }
            }
            Spacer()
        }
        .onReceive(
            systemDataModel.$brightnessValue
                .dropFirst()
        ) { _ in
            isShowBrightnessBar = true
            isShowVolumeBar = false
        }
        .onReceive(
            systemDataModel.$volumeValue
                .dropFirst()
        ) { _ in
            isShowBrightnessBar = false
            isShowVolumeBar = true
        }
    }
}

#Preview {
    SystemDisplayView()
        .background(.black.opacity(0.3))
        .environmentObject(SystemDataModel())
}
