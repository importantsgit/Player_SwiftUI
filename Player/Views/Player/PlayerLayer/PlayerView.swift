//
//  PlayerView.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
//

import AVFoundation
import AVKit
import MediaPlayer
import SwiftUI

struct PlayerView: UIViewRepresentable {
    @EnvironmentObject var playerManager: PlayerManager
    
    func makeUIView(context: Context) -> UIPlayerView {
        print("재훈 makeUIView")
        let view = UIPlayerView(playerState: playerManager.playerState)
        return view
    }
    
    // 부모 뷰가 렌더링 된다면 해당 함수 호출
    // 관련된 상태 변수가 변했을 경우
    // 앱 생명주기 이벤트 발생 시
    func updateUIView(_ uiView: UIPlayerView, context: Context) {
        // FIXME: - 플레이어 갱신 문제 > 오디오 모드에서 문제 생김
        if uiView.player?.currentItem !== playerManager.player?.currentItem {
            print("playerChange")
            uiView.player = playerManager.player
        }
        
        // State Update
        uiView.updateState(playerManager.playerState)
    }
    
    // UIKit의 Delegate Pattern을 SwiftUI에서 사용할 수 있게 해주는 브릿지 역할
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, AVPictureInPictureControllerDelegate {
        var parent: PlayerView
        
        init(parent: PlayerView) {
            self.parent = parent
        }
        
        func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
            print("📺 [VideoPlayer][pip] willStart")
        }
        func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
            print("📺 [VideoPlayer][pip] didStart")
        }
        func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
            print("📺 [VideoPlayer][pip] didStop")
        }
        func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
            print("📺 [VideoPlayer][pip] willStop")
        }
        func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
            print("📺 [VideoPlayer][pip] complete pip")
            completionHandler(true)
        }
        func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
            print("📺 [VideoPlayer][pip] failedToStartPictureInPictureWithError err: \(error.localizedDescription)")
        }
    }
}
