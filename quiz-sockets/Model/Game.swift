//
//  Game.swift
//  quiz-sockets
//
//  Created by Morten Saabye Kristensen on 15/10/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import Foundation
import UIKit
class Game {
    var playersToStart: Int?
    var players = [String: UIView]()
    var playerCount = 0
    var pointsToWin: Int?
    var moderator: String?
    var otherPlayers: [String]?
}
