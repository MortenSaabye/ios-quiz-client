//
//  WaitingViewController.swift
//  quiz-sockets
//
//  Created by Morten Saabye Kristensen on 10/10/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import UIKit
import SnapKit
import SocketIO

class WaitingViewController: UIViewController {
    var client: Client!
    var game = Game()
    var player: Player?
    weak var topGuide: UIView?
    @IBOutlet weak var playersNeeded: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        addHandlers()
        let channel = ["channel": self.client.channel?["channel"],"name":self.client.channel?["name"]]
        self.client.socket.emit("subscribe", with: [channel])
        // Do any additional setup after loading the view.
              
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func addHandlers() {
        client.socket.on("joinSucces") {[weak self] data, ack in
            if let players = data[0] as? [[String: Any]] {
                self?.game.playerCount = players.count - 1
                for player in players {
                    if player["isModerator"] as? Int == 1, let moderatorId = player["id"] as? String,let moderatorName = player["name"] as? String {
                        self?.game.moderator = moderatorId
                        self?.createBoxForModerator(moderatorName)
                    } else {
                        self?.createBoxForPlayer(player["name"] as! String)
                    }
                }
            }
            if let playersToStart = data[1] as? Int {
                self?.game.playersToStart = playersToStart
                self?.updatePlayerCount()
            }
            if let pointsToWin = data[2] as? Int {
                self?.game.pointsToWin = pointsToWin
            }
            if let playerData = data[3] as? [String:Any] {
                self?.player = Player(data: playerData)
            }
            if data[4] as? Bool == true {
                self?.client.socket.emit("ready")
            }
        }
        client.socket.on("newPlayer") { [weak self] data, ack in
            if let name = data[0] as? String {
                self?.createBoxForPlayer(name)
                self?.incrementPlayers()
                self?.updatePlayerCount()
            }
        }
        client.socket.on("disconnection") { [weak self] data, ack in
            if let name = data[0] as? String {
                let box = self?.game.players[name]
                box?.removeFromSuperview()
                self?.decrementPlayers()
                self?.updatePlayerCount()
            }
        }
        
        client.socket.on("startGame") { [weak self] data, ack in
            if let serializedPlayers = data[0] as? [[String: Any]] {
                var players = [Player]()
                for serializedPlayer in serializedPlayers {
                    let player = Player(data: serializedPlayer)
                    players.append(player)
                }
                if self?.player?.isModerator == true {
                    self?.performSegue(withIdentifier: "ReadyToAskSegue", sender: players)
                } else {
                    self?.performSegue(withIdentifier: "ReadyToPlaySegue", sender: players)
                }
            }
        }
        
        client.socket.on("destroyed") { [weak self] data, ack in
            if data[0] as? String == self?.client.channel?["channel"] {
                self?.performSegue(withIdentifier: "channelDestroyedWaiting", sender: nil)
            }
        }
        client.socket.on("statusChange") { [weak self] data, ack in
            self?.performSegue(withIdentifier: "lostConnWaiting", sender: nil)
        }
    }
    
//    MARK: Private methods
    private func createBoxForModerator(_ name: String) {
        let box = UIView()
        self.view.addSubview(box)
        box.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view).inset(12)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(12)
            make.height.equalTo(50)
        }
        box.layer.cornerRadius = 10
        box.backgroundColor = UIColor(named: "Green")
        self.topGuide = box
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.textColor = .white
        box.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(box).offset(6)
            make.left.equalTo(box).offset(8)
        }
        let label = UILabel()
        label.text = "Moderator"
        label.textColor = .white
        box.addSubview(label)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        label.snp.makeConstraints { (make) in
            make.bottom.equalTo(box).offset(-6)
            make.left.equalTo(box).offset(8)
        }
        if self.player?.isModerator == true {
            let label = UILabel()
            label.text = "You are the moderator"
            label.textColor = .white
            box.addSubview(label)
            label.font = UIFont.boldSystemFont(ofSize: 14)
            
            label.snp.makeConstraints { (make) in
                make.bottom.equalTo(box).offset(-6)
                make.right.equalTo(box).offset(-8)
            }
        }
    }
    
    private func createBoxForPlayer(_ name: String) {
        let box = UIView()
        self.view.addSubview(box)
        box.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view).inset(12)
            make.top.equalTo(self.topGuide!.snp.bottom).inset(-12)
            make.height.equalTo(50)
        }
        self.topGuide = box
        self.game.players[name] = box
        box.layer.cornerRadius = 10
        box.backgroundColor = UIColor(named: "Yellow")
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.textColor = .black
        box.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(box).offset(6)
            make.left.equalTo(box).offset(8)
        }
        let label = UILabel()
        label.text = "Player"
        label.textColor = .black
        box.addSubview(label)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        label.snp.makeConstraints { (make) in
            make.bottom.equalTo(box).offset(-6)
            make.left.equalTo(box).offset(8)
        }
    }
    private func incrementPlayers() {
        self.game.playerCount = self.game.playerCount + 1
    }
    private func decrementPlayers() {
        self.game.playerCount = self.game.playerCount - 1
    }
    private func updatePlayerCount() {
        playersNeeded.title = "\(self.game.playersToStart! - self.game.playerCount)"
    }
    
    // MARK: - Navigation
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let players = sender as? [Player] {
            if let destination = segue.destination as? ModeraterViewController {
                destination.client = self.client
                destination.players = players
                destination.player = self.player
                destination.pointsToWin = self.game.pointsToWin
            }
            if let destination = segue.destination as? PlayerViewController {
                destination.client = self.client
                destination.players = players
                destination.player = self.player
                destination.pointsToWin = self.game.pointsToWin
            }
        }
    }
}
