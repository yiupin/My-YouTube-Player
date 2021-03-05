//
//  Playlist+CoreDataProperties.swift
//  
//
//  Created by Pin Yiu on 28/1/2021.
//
//

import Foundation
import CoreData


extension Playlist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Playlist> {
        return NSFetchRequest<Playlist>(entityName: "Playlist")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var songs: [SongModelCD]?

}
