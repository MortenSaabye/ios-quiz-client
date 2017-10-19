//
//  PlayerView.swift
//  quiz-sockets
//
//  Created by Morten Saabye Kristensen on 18/10/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import Foundation
import SnapKit
class PlayerView {
    var players: [Player]
    var context: UIViewController
    init(context: UIViewController, players: [Player]) {
        self.context = context
        self.players = players
        let container = UIView()
        context.view.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(context.view)
            make.height.equalTo(64 * (players.count - 1))
        }
        for player in players {
            if player.isModerator {
                continue
            }
            let view = player.view
            container.addSubview(view)
            view.backgroundColor = UIColor(named: "Yellow")
            view.layer.cornerRadius = 10
            let distanceFromTop = CGFloat(((container.subviews.count - 1) * 52) + 12)
            view.snp.makeConstraints({ (make) in
                make.left.top.right.equalTo(container).inset(UIEdgeInsets(top: distanceFromTop, left: 12, bottom: 12, right: 12))
                make.height.equalTo(40)
            })
            
            let nameLabel = UILabel()
            nameLabel.text = player.name
            nameLabel.numberOfLines = 0
            view.addSubview(nameLabel)
            nameLabel.snp.makeConstraints({ (make) in
                make.top.bottom.left.equalTo(view).inset(8)
            })
            let pointsLabel = UILabel()
            pointsLabel.text = String(player.points)
            pointsLabel.font = UIFont.boldSystemFont(ofSize: 22)
            view.addSubview(pointsLabel)
            pointsLabel.snp.makeConstraints({ (make) in
                make.top.right.bottom.equalTo(view).inset(8)
            })
        }
    }
    func addPoint(id: String) {
        for player in players {
            if player.id == id {
                player.points = player.points + 1
                if let pointsView = player.view.subviews.last as? UILabel {
                    pointsView.text = String(player.points)
                }
            }
        }
    }
}
