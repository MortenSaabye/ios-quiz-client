//
//  Player.swift
//  quiz-sockets
//
//  Created by Morten Saabye Kristensen on 17/10/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import Foundation
import UIKit
class Player {
    let name: String
    let id: String
    var points = 0
    let view = UIView()
    let isModerator: Bool
    init(name: String, id: String, isModerator: Bool) {
        self.name = name
        self.id = id
        self.isModerator = isModerator
    }
    init(data: [String : Any]){
        guard let name = data["name"] as? String else {
            fatalError("No name")
        }
        guard let id = data["id"]  as? String else {
            fatalError("No id")
        }
        guard let isModerator = data["isModerator"] as? Bool else {
            fatalError("No isModerator")
        }
        self.name = name
        self.id = id
        self.isModerator = isModerator
    }
}
