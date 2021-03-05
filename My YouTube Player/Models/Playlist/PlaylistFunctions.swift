//
//  PlaylistFunctions.swift
//  My YouTube Player
//
//  Created by Pin Yiu on 25/1/2021.
//  Copyright © 2021 Pin Yiu. All rights reserved.
//

import Foundation

class PlaylistFunctions {
    
    static func createPlaylist(playlistModel: PlaylistModel) {
        Data.playlistModels.append(playlistModel)
        DataFunctions.addPlaylistData(playlistModel: playlistModel)
    }
    
    static func readPlaylist(completion: @escaping () -> ()) {
        DispatchQueue.main.async {
            Data.playlistModels = DataFunctions.fetchPlaylistData()
            completion()
        }
    }
    
    static func renamePlaylist(index: Int, name: String) {
        let playlist = Data.playlistModels[index]
        playlist.name = name
        Data.playlistModels.remove(at: index)
        Data.playlistModels.insert(playlist, at: index)
        DataFunctions.updatePlaylistData(id: Data.playlistModels[index].id, playlistModel: Data.playlistModels[index])
    }
    
    static func reorderPlaylist(sourceIndex: Int, destinationIndex: Int) {
        let playlist = Data.playlistModels[sourceIndex]
        Data.playlistModels.remove(at: sourceIndex)
        Data.playlistModels.insert(playlist, at: destinationIndex)
    }
    
    static func deletePlaylist(index: Int) {
        let songs =  Data.playlistModels[index].songs
        for song in songs {
            if song.isDownloaded == true {
                BMPlayerViewControllerManager.shared.deleteDownload(vid: song.id, compeltion: {})
            }
        }
        DataFunctions.deletePlaylistData(id: Data.playlistModels[index].id)
        Data.playlistModels.remove(at: index)
    }
    
    static func addSong(id: UUID, songModel: SongModel) {
        if let index = PlaylistFunctions.getIndexFromID(id: id) {
            Data.playlistModels[index].songs.append(songModel)
            DataFunctions.updatePlaylistData(id: Data.playlistModels[index].id, playlistModel: Data.playlistModels[index])
        }
    }
    
    static func renameSong(id: UUID, songIndex: Int, name: String) {
        if let index = PlaylistFunctions.getIndexFromID(id: id) {
            let song = Data.playlistModels[index].songs[songIndex]
            song.name = name
            Data.playlistModels[index].songs.remove(at: songIndex)
            Data.playlistModels[index].songs.insert(song, at: songIndex)
            DataFunctions.updatePlaylistData(id: id, playlistModel: Data.playlistModels[index])
        }
    }
    
    static func reorderSong(id: UUID, sourceIndex: Int, destinationIndex: Int) {
        if let index = PlaylistFunctions.getIndexFromID(id: id) {
            let song = Data.playlistModels[index].songs[sourceIndex]
            Data.playlistModels[index].songs.remove(at: sourceIndex)
            Data.playlistModels[index].songs.insert(song, at: destinationIndex)
            DataFunctions.updatePlaylistData(id: id, playlistModel: Data.playlistModels[index])
        }
    }
    
    static func updateIsSongDownloaded(id: UUID, songIndex: Int, isDownloaded: Bool) {
        if let index = PlaylistFunctions.getIndexFromID(id: id) {
            let song = Data.playlistModels[index].songs[songIndex]
            song.isDownloaded = isDownloaded
            DataFunctions.updatePlaylistData(id: id, playlistModel: Data.playlistModels[index])
        }
    }
    
    static func removeSong(id: UUID, songIndex: Int) {
        if let index = PlaylistFunctions.getIndexFromID(id: id) {
            if Data.playlistModels[index].songs[songIndex].isDownloaded == true {
                BMPlayerViewControllerManager.shared.deleteDownload(vid: Data.playlistModels[index].songs[songIndex].id, compeltion: {})
            }
            Data.playlistModels[index].songs.remove(at: songIndex)
            DataFunctions.updatePlaylistData(id: id, playlistModel: Data.playlistModels[index])
        }
    }
    
    static func getIndexFromID(id: UUID) -> Int? {
        if let index = Data.playlistModels.firstIndex(where: { (playlist) -> Bool in
            return playlist.id == id
        }) {
            return index
        } else {
            return nil
        }
    }
}
