// Interface.swift
// Copyright (c) 2021 Joe Blau

#if canImport(MediaPlayer) && os(iOS)
    import ComposableArchitecture
    import Foundation
    import MediaPlayer

    public struct AppleMusicManager {
        public enum Action: Equatable {
            case authorizationStatus(MPMediaLibraryAuthorizationStatus)
            case nowPlayingItemDidChange(NowPlayingMedia)
            case playbackStateDidChange(MPMusicPlaybackState)
        }

        public struct Error: Swift.Error, Equatable {
            public let error: NSError?

            public init(_ error: Swift.Error?) {
                self.error = error as NSError?
            }
        }

        public var connectionStatus: (AnyHashable) -> ConnectionStatus = { _ in _unimplemented("connectionStatus") }

        // MARK: - Variables

        var create: (AnyHashable) -> Effect<Action, Never> = { _ in _unimplemented("create") }
        var destroy: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("destroy") }
        var authorize: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("authorize") }
        var play: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("play") }
        var pause: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("pause") }
        var skipForward: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("skipForward") }
        var skipBackward: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("skipBackward") }
        var setVolume: (AnyHashable, Float) -> Effect<Never, Never> = { _,_ in _unimplemented("setVolume") }
        // MARK: - Functions

        public func create(id: AnyHashable) -> Effect<Action, Never> {
            create(id)
        }

        public func destroy(id: AnyHashable) -> Effect<Never, Never> {
            destroy(id)
        }
        
        public func authorize(id: AnyHashable) -> Effect<Never, Never> {
            authorize(id)
        }
        
        public func play(id: AnyHashable) -> Effect<Never, Never> {
            play(id)
        }

        public func pause(id: AnyHashable) -> Effect<Never, Never> {
            pause(id)
        }
        
        public func skipForward(id: AnyHashable) -> Effect<Never, Never> {
            skipForward(id)
        }

        public func skipBackward(id: AnyHashable) -> Effect<Never, Never> {
            skipBackward(id)
        }
        
        public func setVolume(id: AnyHashable, level: Float) -> Effect<Never, Never> {
            setVolume(id, level)
        }
    }
#endif
