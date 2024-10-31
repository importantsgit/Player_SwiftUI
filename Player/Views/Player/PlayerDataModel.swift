//
//  PlayerDataModel.swift
//  Player
//
//  Created by Importants on 10/18/24.
//

import AVFoundation
import Combine
import SwiftUI

final class PlayerDataModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var state: UIPlayerView.PlayerState
    @Published var isBuffering: Bool = false                    // 버퍼링 여부
    @Published var isInitialized: Bool = false                  // 초기화 여부
    @Published var isCurrentItemFinished: Bool = false          // 영상이 끝났는지에 대한 여부
    @Published var playerTimeState: PlayerTimeState = .pause    // 영상 상태 여부
    @Published var playerError: Error?                          // 에러 여부
    
    // MARK: 해당 Subject에 send 시, 5초 후 timerPublisher가 sink됨
    var showControllerSubject = PassthroughSubject<Bool, Never>()
    lazy var timerPublisher: AnyPublisher<Void, Never> = {
        showControllerSubject
            .filter { $0 } // true 만
            .map { _ in () } // Void로 변환
            .debounce(for: .seconds(5), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    var isPlaying: Bool {
        guard let player = player else { return false }
        return player.timeControlStatus == .playing ? true : false
        // .waitingToPlayAtSpecifiedRate: 플레이어가 재생을 시작하려고 하지만, 아직 실제로 재생되지 않은 상태
    }
    
    init(url: URL?, state: UIPlayerView.PlayerState = .init()) {
        self.state = state
        if let url { setPlayer(with: url) }
        // 현재 init에 오래 걸리는 Task가 존재
        // 이럴 경우
    }
    func setPlayer(with url: URL) {
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey: true] // 정확한 길이와 타이밍 정보를 요청
        let asset = AVURLAsset(url: url, options: options)
        
        Task {
            do {
                // 해당 Key 값을 이용하기 위해서 iOS 16.0 이후부터 concurrency 사용
                // playable: 에셋이 재생 가능한지 판단 재생 가능하다면 재생 로직을 실행하고, 그렇지 않다면 사용자에게 적절한 메시지를 표시
                // hasProtectedContent: 속성을 확인하여 에셋이 보호된 콘텐츠인지 판단. 보호된 콘텐츠라면 필요한 DRM 처리 로직을 추가로 실행
                let (isPlayable, hasProtectedContent) = try await asset.load(.isPlayable, .hasProtectedContent)
                // 바로 실행 가능한지
                if isPlayable {
                 
                    // 보호된 컨텐츠
                    if hasProtectedContent {
                        
                    }
                    else {
                        await MainActor.run {
                            let playerItem = AVPlayerItem(asset: asset)
                            if self.player == nil {
                                let player = AVPlayer()
                                self.player = player
                                self.setupPlayerObservers()
                            }
                            self.player?.replaceCurrentItem(with: playerItem)
                            self.player?.play()
                        }
                    }
                }
            }
        }
    }
    
    private func setupPlayerObservers() {
        NotificationCenter.default.publisher(for: AVPlayerItem.didPlayToEndTimeNotification)
            .compactMap { $0.object as? AVPlayerItem }
            .filter { [weak self] playerItem in
                self?.player?.currentItem == playerItem
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.isCurrentItemFinished = true
            }
            .store(in: &cancellables)
        
        player?.publisher(for: \.timeControlStatus)
        // - Publishing changes from within view updates is not allowed, this will cause undefined behavior.
        // 뷰 업데이트를 Main Thread에서 진행
        // 현재 로직들은 다른 Thread에서 진행 따라서 ViewUpdate와 Publishing간의 충돌이 발생할 수 있음
        // 따라서 MainThread에서 sink하도록 설정 (동기적으로 실행)
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                switch status {
                case .paused:
                    self?.playerTimeState = .pause
                case .waitingToPlayAtSpecifiedRate:
                    self?.playerTimeState = .buffering
                case .playing:
                    self?.playerTimeState = .playing
                @unknown default:
                    self?.playerTimeState = .pause
                }
            }
            .store(in: &cancellables)
        
        player?.currentItem?.publisher(for: \.status)
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                switch status {
                case .readyToPlay:
                    self?.isInitialized = true
                case .failed:
                    self?.isInitialized = false
                    self?.playerError = self?.player?.currentItem?.error
                default:
                    self?.isInitialized = false
                }
            }
            .store(in: &cancellables)
    }
}
