// Live.swift
// Copyright (c) 2021 Joe Blau

#if canImport(MediaPlayer) && os(iOS)
    import Combine
    import ComposableArchitecture
    import Foundation
    import MediaPlayer

    public extension AppleMusicManager {
        static let connectionStatusKey = "apple_music_manager_connection_status_key"
        static let live: AppleMusicManager = { () -> AppleMusicManager in

            var manager = AppleMusicManager()

            manager.connectionStatus = { id in return dependencies[id]?.connectionStatus ?? .unknown }
            
            manager.create = { id in

                Effect.run { subscriber in
                    let systemMediaPlayer = MPMusicPlayerController.systemMusicPlayer
                    let notificationCenter = NotificationCenter.default
                    let delegate = AppleMusicManagerDelegate(subscriber)

                    notificationCenter.addObserver(delegate,
                                                   selector: #selector(delegate.handleMusicPlayerControllerNowPlayingItemDidChange),
                                                   name: .MPMusicPlayerControllerNowPlayingItemDidChange,
                                                   object: systemMediaPlayer)

                    notificationCenter.addObserver(delegate,
                                                   selector: #selector(delegate.handleMusicPlayerControllerPlaybackStateDidChange),
                                                   name: .MPMusicPlayerControllerPlaybackStateDidChange,
                                                   object: systemMediaPlayer)

                    dependencies[id] = Dependencies(
                        connectionStatus: ConnectionStatus(rawValue: UserDefaults.standard.integer(forKey: "\(AppleMusicManager.self)_status_key")) ?? .unknown,
                        systemMediaPlayer: systemMediaPlayer,
                        notificationCenter: notificationCenter,
                        delegate: delegate,
                        subscriber: subscriber
                    )

                    systemMediaPlayer.beginGeneratingPlaybackNotifications()
                    delegate.handleMusicPlayerControllerPlaybackStateDidChange()
                    delegate.handleMusicPlayerControllerNowPlayingItemDidChange()

                    return AnyCancellable {
                        dependencies[id] = nil
                    }
                }
            }

            manager.destroy = { id in
                .fireAndForget {
                    let statusKey = dependencies[id]?.connectionStatus ?? .unknown
                    UserDefaults.standard.set(statusKey.rawValue, forKey: "\(AppleMusicManager.self)_status_key")
                    dependencies[id]?.systemMediaPlayer.endGeneratingPlaybackNotifications()
                    dependencies[id]?.subscriber.send(completion: .finished)
                    dependencies[id] = nil
                }
            }
            
            manager.authorize = { id in
                .fireAndForget {
                    MPMediaLibrary.requestAuthorization { status in
                        let statusKey: ConnectionStatus = status == .authorized ? .connected : .disconnected
                        UserDefaults.standard.set(statusKey.rawValue, forKey: "\(AppleMusicManager.self)_status_key")
                        dependencies[id]?.subscriber.send(.authorizationStatus(status))
                    }
                }
            }
            
            manager.play = { id in
                .fireAndForget {
                    dependencies[id]?.systemMediaPlayer.play()
                }
                .subscribe(on: DispatchQueue.main)
                .eraseToEffect()
            }

            manager.pause = { id in
                .fireAndForget {
                    dependencies[id]?.systemMediaPlayer.pause()
                }
                .subscribe(on: DispatchQueue.main)
                .eraseToEffect()
            }
            
            manager.skipForward = { id in
                .fireAndForget {
                    dependencies[id]?.systemMediaPlayer.skipToNextItem()
                }
                .subscribe(on: DispatchQueue.main)
                .eraseToEffect()
            }

            manager.skipBackward = { id in
                .fireAndForget {
                    guard let currentPlaybackTime = dependencies[id]?.systemMediaPlayer.currentPlaybackTime else { return }
                    switch currentPlaybackTime {
                    case 0 ... 10: dependencies[id]?.systemMediaPlayer.skipToPreviousItem()
                    default: dependencies[id]?.systemMediaPlayer.skipToBeginning()
                    }
                }
                .subscribe(on: DispatchQueue.main)
                .eraseToEffect()
            }
            
            manager.setVolume = { id, level in
                .fireAndForget {
                    MPVolumeView.setVolume(level)
                }
            }
            
            return manager
        }()
    }

    private struct Dependencies {
        var connectionStatus: ConnectionStatus
        var systemMediaPlayer: MPMusicPlayerController
        var notificationCenter: NotificationCenter
        let delegate: AppleMusicManagerDelegate
        let subscriber: Effect<AppleMusicManager.Action, Never>.Subscriber
    }

    private var dependencies: [AnyHashable: Dependencies] = [:]

    private class AppleMusicManagerDelegate: NSObject {
        let subscriber: Effect<AppleMusicManager.Action, Never>.Subscriber

        init(_ subscriber: Effect<AppleMusicManager.Action, Never>.Subscriber) {
            self.subscriber = subscriber
        }

        @objc func handleMusicPlayerControllerNowPlayingItemDidChange() {
            let nowPlaying = NowPlayingMedia(artwork: MPMusicPlayerController.systemMusicPlayer.nowPlayingItem?.artwork?.image(at: CGSize(width: 64, height: 64)),
                                             title: MPMusicPlayerController.systemMusicPlayer.nowPlayingItem?.title,
                                             artist: MPMusicPlayerController.systemMusicPlayer.nowPlayingItem?.artist)
            subscriber.send(.nowPlayingItemDidChange(nowPlaying))
        }

        @objc func handleMusicPlayerControllerPlaybackStateDidChange() {
            let playbackState = MPMusicPlayerController.systemMusicPlayer.playbackState
            subscriber.send(.playbackStateDidChange(playbackState))
        }
    }

    extension MPVolumeView {
        static func setVolume(_ volume: Float) {
            let volumeView = MPVolumeView()
            let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
                slider?.value = volume
            }
        }
    }
#endif
