//
//  Player.swift
//  quiz-sockets
//
//  Created by Morten Saabye Kristensen on 15/10/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import Foundation
import SocketIO
class Client {
    let socket: SocketIOClient!
    var channel: [String:String]?
    init(socket: SocketIOClient, channel: [String:String]?) {
        self.socket = socket
        self.channel = channel
    }
}
