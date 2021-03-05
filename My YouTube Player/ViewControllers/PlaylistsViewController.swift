//
//  PlaylistsViewController.swift
//  My YouTube Player
//
//  Created by Pin Yiu on 24/1/2021.
//  Copyright © 2021 Pin Yiu. All rights reserved.
//

import UIKit
import SnapKit

class PlaylistsViewController: UIViewController {
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = .darkGray
        return tableView
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
        button.addTarget(self, action: #selector(renamePlaylist), for: .touchUpInside)
        return button
    }()
    
    var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Delete", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.addTarget(self, action: #selector(deletePlaylist), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .gray
        title = "Playlists"
        
        let addImage = UIImage(systemName: "plus")
        let add = UIBarButtonItem(image: addImage, style: .done, target: self, action: #selector(addPlaylist))
        navigationItem.leftBarButtonItems = [add]
        let edit = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(toggleEditMode))
        navigationItem.rightBarButtonItems = [edit]
        
        // Table View
        tableView.frame = view.frame
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelectionDuringEditing = true
        view.addSubview(tableView)
        
        PlaylistFunctions.readPlaylist(completion: { [weak self] in
            self?.tableView.reloadData()
        })
        
        
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
        
        selectionView.addSubview(deleteButton)
        deleteButton.frame = CGRect(x: 0, y: 0, width: 500, height: selectionView.frame.height)
        deleteButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(selectionView)
            make.trailing.equalTo(-10)
        }

    }
    
    
    // Button's actions
    @objc func addPlaylist() {
        let alert = UIAlertController(title: "Add New Playlist", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Enter Playlist Name"
        })
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] action -> Void in
            guard let strongSelf = self else {
                return
            }
        
            if let textField = alert.textFields?[0], var text = textField.text {
                if text.isEmpty {
                    text = "New Playlist \(Data.playlistModels.count+1)"
                }
                PlaylistFunctions.createPlaylist(playlistModel: PlaylistModel(name: text))
                strongSelf.tableView.reloadData()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func toggleEditMode(_ sender: UIBarButtonItem) {
        tableView.isEditing.toggle()
        sender.title = sender.title == "Edit" ? "Done" : "Edit"
        if sender.title == "Edit" {
            selectionView.isHidden = true
        }
    }
    
    @objc func renamePlaylist() {
        if let selectedRow = tableView.indexPathForSelectedRow {
            let alert = UIAlertController(title: "Rename Playlist", message: "", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = Data.playlistModels[selectedRow.row].name
            })
            alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { [weak self] action -> Void in
                guard let strongSelf = self else {
                    return
                }
            
                if let textField = alert.textFields?[0], let text = textField.text {
                    if !text.isEmpty && text != Data.playlistModels[selectedRow.row].name {
                        print("Renamed playlist: \(text)")
                        PlaylistFunctions.renamePlaylist(index: selectedRow.row, name: text)
                        strongSelf.tableView.reloadData()
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func deletePlaylist() {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            var ids = [UUID]()
            for indexPath in selectedRows  {
                ids.append(Data.playlistModels[indexPath.row].id)
            }
            for id in ids {
                if let index = Data.playlistModels.firstIndex(where: { (playlist) -> Bool in
                    return playlist.id == id
                }) {
                    PlaylistFunctions.deletePlaylist(index: index)
                }
                
            }
            tableView.deleteRows(at: selectedRows, with: .automatic)
            selectionView.isHidden = true
        }
    }
    
}

extension PlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Data.playlistModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        if let textLabel = cell.textLabel {
            textLabel.text = Data.playlistModels[indexPath.row].name
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
            let playlistVC = PlaylistViewController()
            playlistVC.title = Data.playlistModels[indexPath.row].name
            playlistVC.id = Data.playlistModels[indexPath.row].id
            playlistVC.songs = Data.playlistModels[indexPath.row].songs
            navigationController?.pushViewController(playlistVC, animated: true)
        } else {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            if let count = tableView.indexPathsForSelectedRows?.count, count > 0 {
                selectionView.isHidden = false
                deleteButton.setTitle("Delete(\(count))", for: .normal)
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
                deleteButton.setTitle("Delete(\(count))", for: .normal)
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
        PlaylistFunctions.reorderPlaylist(sourceIndex: sourceIndexPath.row, destinationIndex: destinationIndexPath.row)
    }
    
    
}
