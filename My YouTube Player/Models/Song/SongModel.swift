//
//  SongModel.swift
//  My YouTube Player
//
//  Created by Pin Yiu on 27/1/2021.
//  Copyright © 2021 Pin Yiu. All rights reserved.
//

import Foundation

class SongModel {
    var id: String
    var name: String
    var isDownloaded: Bool
    
    init(id: String, name: String, isDownloaded: Bool) {
        self.id = id
        self.name = name
        self.isDownloaded = isDownloaded
    }
}

public class SongModelCD: NSObject, NSCoding {
    public var id: String = ""
    public var name: String = ""
    public var isDownloaded: Bool = false
    
    enum Key: String {
        case id = "id"
        case name = "name"
        case isDownloaded = "isDownloaded"
    }
    
    init(id: String, name: String, isDownloaded: Bool) {
        self.id = id
        self.name = name
        self.isDownloaded = isDownloaded
    }
    
    public override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: Key.id.rawValue)
        aCoder.encode(name, forKey: Key.name.rawValue)
        aCoder.encode(isDownloaded, forKey: Key.isDownloaded.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let mid = aDecoder.decodeObject(forKey: Key.id.rawValue) as! String
        let mname = aDecoder.decodeObject(forKey: Key.name.rawValue) as! String
        let misDownloaded = aDecoder.decodeBool(forKey: Key.isDownloaded.rawValue)
        
        self.init(id: String(mid), name: String(mname), isDownloaded: misDownloaded)
    }
    
    
}
