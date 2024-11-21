//
//  PlayerApp.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
//

import SwiftUI
import SwiftData

@main
struct PlayerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            let url = URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!
            // let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
            ContentView(url: url)
        }
        .modelContainer(sharedModelContainer)
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
}

extension AppDelegate {
    enum OrientationPreferenceState: String {
        case portrait
        case landscape
        case all
        
        var mask: UIInterfaceOrientationMask {
            switch self {
            case .all: return .all
            case .landscape: return .landscape
            case .portrait: return .portrait
            }
        }
        
        func matches(to orientation: UIInterfaceOrientation) -> Bool {
            switch self {
            case .all:
                return true
            case .landscape:
                return orientation.isLandscape
            case .portrait:
                return orientation.isPortrait
            }
        }
    }
    
    static var orientationLock: OrientationPreferenceState = .all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        AppDelegate.orientationLock.mask
    }
}
