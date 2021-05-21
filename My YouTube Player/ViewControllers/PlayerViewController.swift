//
//  PlayerViewController.swift
//  My YouTube Player
//
//  Created by Pin Yiu on 29/1/2021.
//  Copyright © 2021 Pin Yiu. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import XCDYouTubeKit
import BMPlayer
import SnapKit

class PlayerViewController: UIViewController {
    
    override var shouldAutorotate: Bool {
        return true
    }

    var id = UUID()
    var songs = [SongModel]()
    var songIndex = 0
    
    var player = BMPlayerViewControllerManager.shared.player
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = .darkGray
        return tableView
    }()
    
    var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Reload", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        refreshControl.tintColor = .white
        return refreshControl
    }()
    
    var selectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    var isLoop = false
    var isRandom = false
    var timer: Timer?
    
    var loopButton: UIButton = {
        let button = UIButton()
        button.setTitle("Loop", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.addTarget(self, action: #selector(toogleLoop), for: .touchUpInside)
        return button
    }()
    
    var randomButton: UIButton = {
        let button = UIButton()
        button.setTitle("Random", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.addTarget(self, action: #selector(toogleRandom), for: .touchUpInside)
        return button
    }()
    
    var timerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Timer", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.addTarget(self, action: #selector(setTimer), for: .touchUpInside)
        return button
    }()
    
    var downloadButton: UIButton = {
        let button = UIButton()
        button.setTitle("Download", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(player)
        player.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(20)
            make.left.right.equalTo(self.view)
            make.height.equalTo(player.snp.width).multipliedBy(9.0/16.0).priority(750)
        }
        
        player.delegate = self
        
        // Selection View
        view.addSubview(selectionView)
        if let tabBar = tabBarController?.tabBar {
            let frame = CGRect(x: tabBar.frame.minX, y: tabBar.frame.minY-tabBar.frame.height, width: tabBar.frame.width, height: tabBar.frame.height)
            selectionView.frame = frame
        }
        
        selectionView.addSubview(loopButton)
        loopButton.frame = CGRect(x: 0, y: 0, width: 200, height: selectionView.frame.height)
        loopButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(selectionView)
            make.leading.equalTo(10)
        }
        
        selectionView.addSubview(randomButton)
        randomButton.frame = CGRect(x: 0, y: 0, width: 200, height: selectionView.frame.height)
        randomButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(selectionView)
            make.left.equalTo(loopButton.snp.right).offset(10)
        }
        
        selectionView.addSubview(timerButton)
        timerButton.frame = CGRect(x: 0, y: 0, width: 200, height: selectionView.frame.height)
        timerButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(selectionView)
            make.left.equalTo(randomButton.snp.right).offset(10)
        }
        
        selectionView.addSubview(downloadButton)
        downloadButton.frame = CGRect(x: 0, y: 0, width: 200, height: selectionView.frame.height)
        downloadButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(selectionView)
            make.left.equalTo(timerButton.snp.right).offset(10)
        }
        
        // Table View
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints{ (make) in
            make.top.equalTo(player.snp.bottom)
            make.width.equalTo(view)
            make.bottom.equalTo(selectionView.snp.top)
        }
        tableView.refreshControl = refreshControl
        tableView.addSubview(refreshControl)
    }
    
    @objc func toogleLoop() {
        isLoop = !isLoop
        if isLoop {
            loopButton.backgroundColor = .red
        } else {
            loopButton.backgroundColor = .none
        }
    }
    
    @objc func toogleRandom() {
        isRandom = !isRandom
        if isRandom {
            randomButton.backgroundColor = .red
        } else {
            randomButton.backgroundColor = .none
        }
    }
    
    @objc func setTimer() {
        let actionSheet = UIAlertController(title: "Stop After", message: "", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "30 mins", style: .default, handler: { _ in
            self.timer = Timer.scheduledTimer(timeInterval: 1800, target: self, selector: #selector(self.pauseTimer), userInfo: nil, repeats: false)
            self.timerButton.backgroundColor = .red
        })
        actionSheet.addAction(action1)
        let action2 = UIAlertAction(title: "1 hr", style: .default, handler: { _ in
            self.timer = Timer.scheduledTimer(timeInterval: 3600, target: self, selector: #selector(self.pauseTimer), userInfo: nil, repeats: false)
            self.timerButton.backgroundColor = .red
        })
        actionSheet.addAction(action2)
        let action3 = UIAlertAction(title: "2 hrs", style: .default, handler: { _ in
            self.timer = Timer.scheduledTimer(timeInterval: 7200, target: self, selector: #selector(self.pauseTimer), userInfo: nil, repeats: false)
            self.timerButton.backgroundColor = .red
        })
        actionSheet.addAction(action3)
        let action4 = UIAlertAction(title: "Remove Timer", style: .default, handler: { _ in
            if self.timer != nil {
                 self.timer?.invalidate()
            }
            self.timerButton.backgroundColor = .none
        })
        actionSheet.addAction(action4)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            if let currentPopoverpresentioncontroller = actionSheet.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = timerButton
                currentPopoverpresentioncontroller.sourceRect = timerButton.bounds
                currentPopoverpresentioncontroller.permittedArrowDirections = UIPopoverArrowDirection.down
                self.present(actionSheet, animated: true, completion: nil)
            }
        } else {
            present(actionSheet, animated: true)
        }
        
    }
    
    @objc func pauseTimer() {
        player.pause()
        self.timerButton.backgroundColor = .none
    }
    
    @objc func download() {
        guard songIndex < songs.count else { return }
        downloadButton.setTitle("Downloading", for: .normal)
        downloadButton.backgroundColor = .yellow
        downloadButton.isEnabled = false
        BMPlayerViewControllerManager.shared.download(vid: songs[songIndex].id, compeltion: {
            self.downloadButton.setTitle("Downloaded", for: .normal)
            self.downloadButton.isEnabled = true
            self.downloadButton.backgroundColor = .red
            self.songs[self.songIndex].isDownloaded = true
            PlaylistFunctions.updateIsSongDownloaded(id: self.id, songIndex: self.songIndex, isDownloaded: true)
            self.downloadButton.removeTarget(self, action: #selector(self.download), for: .touchUpInside)
            self.downloadButton.addTarget(self, action: #selector(self.deleteDownload), for: .touchUpInside)

        })
    }
    
    @objc func deleteDownload() {
        guard songIndex < songs.count else { return }
        downloadButton.setTitle("Removing", for: .normal)
        downloadButton.backgroundColor = .yellow
        downloadButton.isEnabled = false
        BMPlayerViewControllerManager.shared.deleteDownload(vid: songs[songIndex].id, compeltion: {
            self.downloadButton.setTitle("Download", for: .normal)
            self.downloadButton.isEnabled = true
            self.downloadButton.backgroundColor = .none
            self.songs[self.songIndex].isDownloaded = false
            PlaylistFunctions.updateIsSongDownloaded(id: self.id, songIndex: self.songIndex, isDownloaded: false)
            self.downloadButton.removeTarget(self, action: #selector(self.deleteDownload), for: .touchUpInside)
            self.downloadButton.addTarget(self, action: #selector(self.download), for: .touchUpInside)
        })
        
    }
    
    func checkIsDownloaded() {
        if songs[songIndex].isDownloaded {
            downloadButton.setTitle("Downloaded", for: .normal)
            downloadButton.backgroundColor = .red
            downloadButton.removeTarget(self, action: #selector(download), for: .touchUpInside)
            downloadButton.addTarget(self, action: #selector(deleteDownload), for: .touchUpInside)

        } else {
            downloadButton.setTitle("Download", for: .normal)
            downloadButton.backgroundColor = .none
            downloadButton.removeTarget(self, action: #selector(deleteDownload), for: .touchUpInside)
            downloadButton.addTarget(self, action: #selector(download), for: .touchUpInside)
        }
    }
    
    @objc func updatePlaylist() {
        if let index = PlaylistFunctions.getIndexFromID(id: id) {
            songs = Data.playlistModels[index].songs
            tableView.reloadData()
            refreshControl.endRefreshing()
        } else {
            refreshControl.endRefreshing()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -80 {
            if !self.refreshControl.isRefreshing {
                updatePlaylist()
            }
        }
    }
    
}

extension PlayerViewController: BMPlayerDelegate {
    func bmPlayer(player: BMPlayer, playerStateDidChange state: BMPlayerState) {
//        print("| BMPlayerDelegate | playerStateDidChange | state - \(state)")
        if state == .playedToTheEnd {
            player.pause()
            if isRandom {
                songIndex = Int.random(in: 0..<songs.count)
                BMPlayerViewControllerManager.shared.play(songModel: songs[songIndex])
                checkIsDownloaded()
            } else {
                let nextIndex = songIndex+1
                if nextIndex < songs.count {
                    songIndex = nextIndex
                    BMPlayerViewControllerManager.shared.play(songModel: songs[songIndex])
                    checkIsDownloaded()
                } else if isLoop {
                    songIndex = 0
                    BMPlayerViewControllerManager.shared.play(songModel: songs[songIndex])
                    checkIsDownloaded()
                }
            }
            tableView.reloadData()
        }
    }
    
    func bmPlayer(player: BMPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
//        print("| BMPlayerDelegate | loadedTimeDidChange | \(loadedDuration) of \(totalDuration)")
    }
    
    func bmPlayer(player: BMPlayer, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
//        print("| BMPlayerDelegate | playTimeDidChange | \(currentTime) of \(totalTime)")
    }
    
    func bmPlayer(player: BMPlayer, playerIsPlaying playing: Bool) {
//        print("| BMPlayerDelegate | playerIsPlaying | playing - \(playing)")
    }
    
    func bmPlayer(player: BMPlayer, playerOrientChanged isFullscreen: Bool) {
        player.snp.remakeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            if let tabBarController = tabBarController {
                if isFullscreen {
                    make.bottom.equalTo(view.snp.bottom)
                    tabBarController.tabBar.isHidden = true
                } else {
                    make.height.equalTo(view.snp.width).multipliedBy(9.0/16.0).priority(500)
                    tabBarController.tabBar.isHidden = false
                }
            }
            
        }
    }
}

extension PlayerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        if let textLabel = cell.textLabel {
            textLabel.text = songs[indexPath.row].name
            textLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            textLabel.textColor = .white
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .gray
        if (indexPath.row == songIndex) {
            cell.backgroundColor = .lightGray
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        player.pause()
        songIndex = indexPath.row
        BMPlayerViewControllerManager.shared.play(songModel: songs[songIndex])
        checkIsDownloaded()
        tableView.reloadData()
    }
}
