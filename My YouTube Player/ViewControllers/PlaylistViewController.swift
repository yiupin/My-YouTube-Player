//
//  PlaylistViewController.swift
//  My YouTube Player
//
//  Created by Pin Yiu on 24/1/2021.
//  Copyright © 2021 Pin Yiu. All rights reserved.
//

import UIKit
import AVKit
import XCDYouTubeKit

class PlaylistViewController: UIViewController {
    
    var id = UUID()
    var songs = [SongModel]()
    
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
    
    var renameButton: UIButton = {
        let button = UIButton()
        button.setTitle("Rename", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.addTarget(self, action: #selector(renameSong), for: .touchUpInside)
        return button
    }()
    
    var removeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Remove", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.addTarget(self, action: #selector(removeSong), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .gray
        
        let edit = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(toggleEditMode))
        navigationItem.rightBarButtonItems = [edit]
        
        // Table View
        tableView.frame = view.frame
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelectionDuringEditing = true
        view.addSubview(tableView)
        tableView.refreshControl = refreshControl
        tableView.addSubview(refreshControl)
        
        // Selection View
        view.addSubview(selectionView)
        selectionView.isHidden = true
        if let tabBar = ((parent as? UINavigationController)?.parent as? TabBarController)?.tabBar {
            let frame = CGRect(x: tabBar.frame.minX, y: tabBar.frame.minY-tabBar.frame.height, width: tabBar.frame.width, height: tabBar.frame.height)
            selectionView.frame = frame
        }
        
        selectionView.addSubview(renameButton)
        renameButton.frame = CGRect(x: 0, y: 0, width: 200, height: selectionView.frame.height)
        renameButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(selectionView)
            make.leading.equalTo(10)
        }
        
        selectionView.addSubview(removeButton)
        removeButton.frame = CGRect(x: 0, y: 0, width: 500, height: selectionView.frame.height)
        removeButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(selectionView)
            make.trailing.equalTo(-10)
        }
    }
    
    // Button's actions
    @objc func toggleEditMode(_ sender: UIBarButtonItem) {
        tableView.isEditing.toggle()
        sender.title = sender.title == "Edit" ? "Done" : "Edit"
        if sender.title == "Edit" {
            selectionView.isHidden = true
        }
    }
    
    @objc func renameSong() {
        if let selectedRow = tableView.indexPathForSelectedRow {
            let alert = UIAlertController(title: "Rename Song", message: "", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { [weak self] textField in
                guard let strongSelf = self else {
                    return
                }
                if let index = PlaylistFunctions.getIndexFromID(id: strongSelf.id) {
                    textField.text = Data.playlistModels[index].songs[selectedRow.row].name
                }
            })
            alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { [weak self] action -> Void in
                guard let strongSelf = self else {
                    return
                }
            
                if let textField = alert.textFields?[0], let text = textField.text, let index = PlaylistFunctions.getIndexFromID(id: strongSelf.id) {
                    if !text.isEmpty && text != Data.playlistModels[index].songs[selectedRow.row].name {
                        PlaylistFunctions.renameSong(id: strongSelf.id, songIndex: selectedRow.row, name: text)
                        strongSelf.tableView.reloadData()
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func removeSong() {
        if let selectedRows = tableView.indexPathsForSelectedRows, let index = PlaylistFunctions.getIndexFromID(id: id) {
            var sids = [String]()
            for indexPath in selectedRows  {
                sids.append(Data.playlistModels[index].songs[indexPath.row].id)
            }
            for sid in sids {
                if let songIndex = Data.playlistModels[index].songs.firstIndex(where: { (song) -> Bool in
                    return song.id == sid
                }) {
                    PlaylistFunctions.removeSong(id: self.id, songIndex: songIndex)
                }
            }
            songs = Data.playlistModels[index].songs
            tableView.deleteRows(at: selectedRows, with: .automatic)
            selectionView.isHidden = true
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
        if scrollView.contentOffset.y < -50 {
            if !self.refreshControl.isRefreshing {
                updatePlaylist()
            }
        }
    }
    
}

extension PlaylistViewController: UITableViewDelegate, UITableViewDataSource {
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
        cell.tintColor = .black
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !tableView.isEditing {
            let song = Data.playlistModels[PlaylistFunctions.getIndexFromID(id: id)!].songs[indexPath.row]
            let vid = song.id
            if let tabBarController = tabBarController {
                tabBarController.selectedIndex = 2
                if let playerVC = tabBarController.viewControllers?[2] as? PlayerViewController {
                    BMPlayerViewControllerManager.shared.play(songModel: songs[indexPath.row])
                    playerVC.songs = songs
                    playerVC.id = id
                    playerVC.songIndex = indexPath.row
                    playerVC.checkIsDownloaded()
                    playerVC.tableView.reloadData()
                }
            }
        } else {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            if let count = tableView.indexPathsForSelectedRows?.count, count > 0 {
                selectionView.isHidden = false
                removeButton.setTitle("Remove(\(count))", for: .normal)
                if count > 1 {
                    renameButton.isHidden = true
                } else {
                    renameButton.isHidden = false
                }
            } else {
                selectionView.isHidden = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
            if let count = tableView.indexPathsForSelectedRows?.count, count > 0 {
                selectionView.isHidden = false
                removeButton.setTitle("Remove(\(count))", for: .normal)
                if count > 1 {
                    renameButton.isHidden = true
                } else {
                    renameButton.isHidden = false
                }
            } else {
                selectionView.isHidden = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if !tableView.isEditing {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        PlaylistFunctions.reorderSong(id: id, sourceIndex: sourceIndexPath.row, destinationIndex: destinationIndexPath.row)
    }
    
}
