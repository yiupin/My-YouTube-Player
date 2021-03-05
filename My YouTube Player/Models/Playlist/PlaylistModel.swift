//
//  PlaylistModel.swift
//  My YouTube Player
//
//  Created by Pin Yiu on 25/1/2021.
//  Copyright © 2021 Pin Yiu. All rights reserved.
//

import Foundation

class PlaylistModel {
    var id: UUID
    var name: String
    var songs: [SongModel] = [SongModel]()
    
    init(name: String) {
        id = UUID()
        self.name = name
    }
    
    init(id: UUID, name: String, songs: [SongModel]) {
        self.id = id
        self.name = name
        self.songs = songs
    }
}
