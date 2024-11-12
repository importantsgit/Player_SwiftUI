//
//  ContentView.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
//

import SwiftUI
import UIKit
import MediaPlayer

struct ContentView: View {
    @State var currentOrientation = UIApplication.orientation
    @State private var viewSize: CGSize = .zero
    @StateObject var playerManager = PlayerManager()
    
    let url: URL
    
    init(url: URL) {
        // 뷰의 생명주기 동안 한번만 초기화되어야 하며, 직접 할당할 수 없음
        self.url = url
    }
    
    var body: some View {
        let isLandscape = currentOrientation.isLandscape
        // 자동으로 Spacing이 들어가기 때문에 0을 입력
        
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if isLandscape == false {
                    NavigationController(title: "Video")
                        .background(.white)
                }
                
                playerContainerView(
                    currentOrientation: $currentOrientation
                )
                .frame(height: isLandscape == false ? geometry.size.width*(9/16) : geometry.size.height)
                    .environmentObject(playerManager)
                    .task {
                        
                    }

                // 해당 뷰가 있어야지 볼륨 컨트롤 시, 시스템 볼륨 컨트롤 UI가 안보임
                // FIXME: 현재 ViewBuilder로 인해 해당 ContainerView 내 PlayerView
                    .hideSystemVolumeView(isHidden: isLandscape == false)
                
                if isLandscape == false {
                    ContentDetailView()
                }
            }
        }
        .detectOrientation($currentOrientation)
        .animation(.easeInOut, value: isLandscape)
        .ignoresSafeArea(.all, edges: isLandscape ? .all : [])
        .task {
            do {
                try await playerManager.setPlayer(with: url)
            }
            catch {
                
            }
        }
    }
}

struct NavigationController: View {
    let title: String
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        HStack {
            Button {
                
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 48, height: 48)
            }
            Spacer()
            Text(title)
            Spacer()
            Button {
                
            } label: {
                Image(systemName: "ellipsis")
                    .frame(width: 48, height: 48)
            }
        }
        .frame(height: 48)
    }
}

struct ContentDetailView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
            }
            Spacer()
        }
        .background(.gray)
    }
}

#Preview {
    ContentView(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
}
