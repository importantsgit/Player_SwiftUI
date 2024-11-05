//
//  PlayerManager.swift
//  Player
//
//  Created by Importants on 10/18/24.
//

import AVFoundation
import AVKit
import Combine
import SwiftUI
import MediaPlayer

/*
 Player의 State와 비즈니스 로직을 포함하는 ViewModel
 
 */

final class PlayerManager: ObservableObject {
    enum ContainerDisplayState: Equatable {
        case normal
        case setting
    }
    
    enum ControllerDisplayState: Equatable {
        case normal
        case system
        case lock
        case audio
        
        enum MainDisplayState: Equatable {
            case normal
            case system
        }
    }
    
    struct PlayerState {
        var mode: PlayerMode
        var videoQuality: PlayerQualityPreset
        var speed: PlayerSpeed
        var gravity: PlayerGravity
        
        init(
            mode: PlayerMode = .pipMode,
            videoQuality: PlayerQualityPreset = .medium,
            speed: PlayerSpeed = .normal,
            gravity: PlayerGravity = .fit
        ) {
            self.mode = mode
            self.videoQuality = videoQuality
            self.speed = speed
            self.gravity = gravity
        }
    }
    
    enum PlayerViewAction {
        // 오디오
        case audioButtonTapped
        case deactivateAudioButtonTapped
        
        // 재생
        case seekBackward(Double)
        case playButtonTapped
        case seekForward(Double)
        
        // 설정
        case speedButtonTapped(PlayerSpeed)
        case qualityButtonTapped(PlayerQualityPreset)
        case gravityButtonTapped(PlayerGravity)
        
        // lock
        case lockButtonTapped
        case unlockButtonTapped
        
        case cancelButtonTapped
    }
    
    @Published var containerDisplayState: ContainerDisplayState = .normal // 플레이어 컨테이너의 GUI
    @Published var controllerDisplayState: ControllerDisplayState = .normal // 플레이어 내 컨트롤러의 GUI
    
    @Published var player: AVPlayer?
    @Published var playerState: PlayerState
    @Published var progressRatio: CGFloat = 0.0
    
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
    
    
    
    private var timeObserverToken: Any? // player의 currentTime 관찰
    
    private var cancellables = Set<AnyCancellable>()
    
    init(state: PlayerState = .init()) {
        self.playerState = state
        setupRemoteCommands()
        setupAudioSession()
    }
    
    func setPlayer(with url: URL) async throws {
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey: true] // 정확한 길이와 타이밍 정보를 요청
        let asset = AVURLAsset(url: url, options: options)
        
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
                        self.player?.allowsExternalPlayback = true // default == true
                        self.player?.replaceCurrentItem(with: playerItem)
                        self.player?.play()
                    }
                }
            }
        }
    }
    
    func handleAction(_ action: PlayerViewAction) {
        var currentState = playerState
        switch action {
        case let .gravityButtonTapped(gravity):
            currentState.gravity = gravity
            
        case let .qualityButtonTapped(quality):
            currentState.videoQuality = quality
            
        case let .speedButtonTapped(speed):
            currentState.speed = speed
            
        case .audioButtonTapped:
            currentState.mode = .audioMode
            controllerDisplayState = .audio
            showControllerSubject.send(true)
            
        case .deactivateAudioButtonTapped:
            currentState.mode = .pipMode
            controllerDisplayState = .normal
            showControllerSubject.send(true)
            
        case .playButtonTapped:
            if isCurrentItemFinished {
                player?.seek(to: .zero)
                return
            }
            
            playerTimeState == .playing ?
            player?.pause() :
            player?.play()
            return
            // state update X
            
        case let .seekBackward(value):
            skipBackward(by: value)
            
        case let .seekForward(value):
            skipForward(by: value)
            
        case .lockButtonTapped:
            controllerDisplayState = .lock
            showControllerSubject.send(true)
            
        case .unlockButtonTapped:
            controllerDisplayState = .normal
            showControllerSubject.send(true)
        }
        print(currentState, playerState)
        updateState(currentState)
    }
    
    deinit {
        if let timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
}

// MARK: - Player Seek
private extension PlayerManager {
    func skipBackward(by interval: TimeInterval) {
        guard let currentTime = player?.currentTime().seconds
        else { return }
        
        let newTime = max(0, currentTime - interval)
        seek(to: newTime)
    }
    
    func skipForward(by interval: TimeInterval) {
        guard let currentTime = player?.currentTime().seconds,
              let duration = player?.currentItem?.duration.seconds
        else { return }
        
        let newTime = min(duration, currentTime + interval)
        seek(to: newTime)
    }
    
    private func seek(to position: TimeInterval) {
        seek(to: CMTime(seconds: position, preferredTimescale: 1))
    }
    
    private func seek(to time: CMTime) {
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { _ in }
    }
}


// MARK: - Update State
private extension PlayerManager {
    func updateState(_ newState: PlayerState) {
        if playerState.mode != newState.mode {
            print("Player mode Changed: \(playerState.mode) => \(newState.mode)")
            updateAudioMode(
                isActive: newState.mode == .audioMode ? true : false
            )
        }
        
        if playerState.speed != newState.speed {
            print("Player speed Changed: \(playerState.speed) => \(newState.speed)")
            player?.rate = newState.speed.value
        }
        
        if playerState.videoQuality != newState.videoQuality {
            print("Player videoQuality is Changed: \(playerState.videoQuality.bitrate), \(playerState.videoQuality.resolution) => \(newState.videoQuality.bitrate), \(newState.videoQuality.resolution)")
            player?.currentItem?.preferredMaximumResolution = newState.videoQuality.resolution
            player?.currentItem?.preferredPeakBitRate = newState.videoQuality.bitrate
        }
        
        playerState = newState
    }

    // MARK: - Audio Mode Method
    func setupRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()
        
        center.playCommand.addTarget { [weak self] _ in
            self?.player?.play()
            return .success
        }
        
        center.pauseCommand.addTarget { [weak self] _ in
            self?.player?.pause()
            return .success
        }
        
        // 초기값 false
        center.playCommand.isEnabled = false
        center.pauseCommand.isEnabled = false
    }
    
    func updateAudioMode(isActive: Bool) {
        let playingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = playingInfoCenter.nowPlayingInfo ?? [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = "콘텐츠 제목"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "콘텐츠 아티스트"
        playingInfoCenter.nowPlayingInfo = isActive ? nowPlayingInfo : [:]
        
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.isEnabled = isActive
        center.pauseCommand.isEnabled = isActive
        // UIApplication.shared.beginReceivingRemoteControlEvents() // 공유된 객체를 사용할 때는 호출할 필요 없음
    }
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch {
            print("error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Setup Observers
private extension PlayerManager {
    func setupPlayerObservers() {
        // NSEC_PER_SEC: 시간 정밀도를 나노초(nanosecond) 단위로 지정하는 것 < 불필요
        // value: 시간 값(정수)
        // timescale: 1초를 나누는 단위(정수)
        // value/timeScale로 계산
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        timeObserverToken = player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: DispatchQueue.global()
        ) { [weak self] time in
            guard let self = self else { return }
            
            let task = Task {
                try Task.checkCancellation()
                
                let progress = self.setProgressRatio()
                await MainActor.run {
                    self.progressRatio = progress
                }
            }
            
            if self.playerTimeState != .playing {
                task.cancel()
            }
        }
        
        NotificationCenter.default.publisher(for: AVPlayerItem.didPlayToEndTimeNotification)
            .compactMap { $0.object as? AVPlayerItem }
            .filter { [weak self] playerItem in
                self?.player?.currentItem == playerItem
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.isCurrentItemFinished = true
                self?.playerTimeState = .ended
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
    
    func setProgressRatio() -> CGFloat {
        guard let duration = player?.currentItem?.duration.seconds,
              let currentTime = player?.currentTime().seconds,
              duration > 0 && currentTime > 0
        else { return 1 }

        print(CGFloat(currentTime / duration))
        
        return CGFloat(currentTime / duration)
    }
}
