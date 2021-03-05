//
//  DataFunctions.swift
//  My YouTube Player
//
//  Created by Pin Yiu on 28/1/2021.
//  Copyright © 2021 Pin Yiu. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataFunctions {
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    static func fetchPlaylistData() -> [PlaylistModel] {
        var playlistModels = [PlaylistModel]()
        do {
            let playlists = try context.fetch(Playlist.fetchRequest()) as! [Playlist]
            
            for playlist in playlists {
                if let id = playlist.id, let name = playlist.name, let songsCD = playlist.songs {
                    var songModels = [SongModel]()
                    for songCD in songsCD {
                        let songModel = SongModel(id: songCD.id, name: songCD.name, isDownloaded: songCD.isDownloaded)
                        songModels.append(songModel)
                    }
                    let playlistModel = PlaylistModel(id: id, name: name, songs: songModels)
                    playlistModels.append(playlistModel)
                }
            }
        }
        catch {
            fatalError("\(error)")
        }
        return playlistModels
    }
    
    static func addPlaylistData(playlistModel: PlaylistModel) {
        let playlist = NSEntityDescription.insertNewObject(forEntityName: "Playlist", into: context) as! Playlist
        
        playlist.id = playlistModel.id
        playlist.name = playlistModel.name
        var songs = [SongModelCD]()
        for song in playlistModel.songs {
            songs.append(SongModelCD(id: song.id, name: song.name, isDownloaded: song.isDownloaded))
        }
        playlist.songs = songs
        
        do {
            try context.save()
        } catch {
            fatalError("\(error)")
        }
    }
    
    static func updatePlaylistData(id: UUID, playlistModel: PlaylistModel) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
        request.predicate = NSPredicate(format: "id == '\(id)'")
        
        do {
            let results = try context.fetch(request) as! [Playlist]
            
            if results.count > 0 {
                var songs = [SongModelCD]()
                for song in playlistModel.songs {
                    songs.append(SongModelCD(id: song.id, name: song.name, isDownloaded: song.isDownloaded))
                }
                results[0].name = playlistModel.name
                results[0].songs = songs
                try context.save()
            }
        } catch {
            fatalError("\(error)")
        }
    }
    
    static func deletePlaylistData(id: UUID) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
        request.predicate = NSPredicate(format: "id == '\(id)'")
        
        do {
            let results = try context.fetch(request) as! [Playlist]
            
            for result in results {
                context.delete(result)
            }
            try context.save()
        } catch {
            fatalError("\(error)")
        }
    }
    
}
