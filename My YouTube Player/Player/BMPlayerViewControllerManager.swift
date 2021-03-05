//
//  BMPlayerViewControllerManager.swift
//  My YouTube Player
//
//  Created by Pin Yiu on 29/1/2021.
//  Copyright © 2021 Pin Yiu. All rights reserved.
//

import Foundation
import AVKit
import XCDYouTubeKit
import BMPlayer

class BMPlayerViewControllerManager: NSObject {
    
    public static let shared = BMPlayerViewControllerManager()
    public var lowQualityMode = false
    
    public var video: XCDYouTubeVideo? {
        didSet {
            guard let video = video else { return }
            guard lowQualityMode == false else {
                guard let streamURL = video.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? video.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ?? video.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] else { fatalError("No stream URL") }
                
                let asset = BMPlayerResource(url: streamURL)
                self.player.setVideo(resource: asset)
                return
            }
            guard let streamURL = video.streamURL else { fatalError("No stream URL")}
            let asset = BMPlayerResource(url: streamURL)
            self.player.setVideo(resource: asset)
        }
    }
    
    public var player: BMPlayer = {
        let controller = BMPlayerControlView()
        controller.backButton.isHidden = true
        controller.fullscreenButton.isHidden = true
        controller.replayButton.isHidden = true
        controller.replayButton.isEnabled = false
        controller.replayButton.alpha = 0
        let player = BMPlayer(customControlView: controller)
        return player
    }()
    
    public func play(songModel: SongModel) {
        if !songModel.id.isEmpty {
            if songModel.isDownloaded {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let filePath = "\(documentsPath)/\(songModel.id).mp4"
                let asset = BMPlayerResource(url: URL(fileURLWithPath: filePath))
                self.player.setVideo(resource: asset)
                self.player.pause()
                self.player.play()
                self.setupRemoteTransportControls()
                self.updateGeneralMetadata(songModel: songModel)
            } else {
                XCDYouTubeClient.default().getVideoWithIdentifier(songModel.id) { (video, error) in
                    guard error == nil else {
                        print("error")
                        return
                    }
                    guard let video = video else { return }
                    
                    BMPlayerViewControllerManager.shared.video = video
                    self.setupRemoteTransportControls()
                    self.updateGeneralMetadata(video: video)
                }
            }
        }
    }
    
    public func download(vid: String, compeltion: @escaping () -> ()) {
        if !vid.isEmpty {
            XCDYouTubeClient.default().getVideoWithIdentifier(vid) { (video, error) in
                guard error == nil else {
                    print("error")
                    return
                }
                guard let video = video else { return }
                
                for url in video.streamURLs {
                    print(url)
                }
//
                guard let streamURL = video.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ?? video.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] else { fatalError("No stream URL") }
//
//                DispatchQueue.global(qos: .background).async {
//                    let url = streamURL
//                    if let urlData = NSData(contentsOf: url) {
//                        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//                        let filePath="\(documentsPath)/\(vid).mp4"
//                        DispatchQueue.main.async {
//                            urlData.write(toFile: filePath, atomically: true)
//                            compeltion()
//                        }
//                    }
//                }
            }
        }
    }
    
    public func deleteDownload(vid: String, compeltion: @escaping () -> ()) {
        if !vid.isEmpty {
            DispatchQueue.global(qos: .background).async {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let filePath = "\(documentsPath)/\(vid).mp4"
                DispatchQueue.main.async {
                    let fileManager = FileManager.default
                    do {
                        try fileManager.removeItem(atPath: filePath)
                        compeltion()
                    } catch {
                        print("Error while deleting file")
                    }
                }
            }
        }
    }
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object:  AVAudioSession.sharedInstance(), queue: .main) { (notification) in
            
            guard let userInfo = notification.userInfo,
                let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                    return
            }
            
            if type == .began {
                self.player.pause()
            } else if type == .ended {
                guard ((try? AVAudioSession.sharedInstance().setActive(true)) != nil) else { return }
                guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                guard options.contains(.shouldResume) else { return }
                self.player.play()
            }
        }
    }
    
    fileprivate let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    
    fileprivate func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [unowned self] event in
            if !self.player.isPlaying {
                self.player.play()
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { event in
            if self.player.isPlaying {
                self.player.pause()
                return .success
            }
            return .commandFailed
        }
    }
    
    fileprivate func updateGeneralMetadata(video: XCDYouTubeVideo) {
        guard player.avPlayer?.currentItem != nil else {
            nowPlayingInfoCenter.nowPlayingInfo = nil
            return
        }
        
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        let title = video.title
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func updateGeneralMetadata(songModel: SongModel) {
        guard player.avPlayer?.currentItem != nil else {
            nowPlayingInfoCenter.nowPlayingInfo = nil
            return
        }
        
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        let title = songModel.name
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
}
