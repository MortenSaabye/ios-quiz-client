//
//  PlayerViewController.swift
//  quiz-sockets
//
//  Created by Morten Saabye Kristensen on 11/10/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import UIKit
import SocketIO
import SnapKit
class PlayerViewController: UIViewController {
    var client: Client!
    var players: [Player]!
    var isGameOver = false
    var player: Player!
    var question: Question?
    var questionView: QuestionView?
    var pointsToWin: Int!
    var playerView: PlayerView?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = player.name
        if let pointsToWin = self.pointsToWin {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Target: \(pointsToWin)", style: .plain, target: nil, action: nil)
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        questionView = QuestionView(context: self, tapGesture: generateTapGesture(number: 4))
        playerView = PlayerView(context: self, players: players)
        addHandlers()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addHandlers() {
        client.socket.on("question") { [weak self] data, ack in
            guard let questionText = data[0] as? String, let options = data[1] as? [String], let correctAnswer = data[2] as? Int, let questionView = self?.questionView else {
                fatalError("Could not find correct data in question.")
            }
            let question = Question(question: questionText, options: options, correctAnswer: correctAnswer)
            self?.question = question
            self?.questionView?.options.forEach {$0.isUserInteractionEnabled = true}
            self?.questionView?.updateInfo(with: "GO!")
            questionView.updateQuestionBox(question: question)
        }
        
        client.socket.on("wrong") { [weak self] data, ack in
            guard let options = self?.questionView?.options, let correctAnswer = self?.question?.correctAnswer else {
                fatalError("properties not available")
            }
            for view in options {
                if view.tag != correctAnswer {
                    view.backgroundColor = UIColor(named: "Orange")
                } else {
                    view.backgroundColor = UIColor(named: "Blue")
                }
            }
            self?.questionView?.updateInfo(with: "Wrong!")
            self?.questionView?.options.forEach {$0.isUserInteractionEnabled = false}
        }
        client.socket.on("nextQuestion") { [weak self] data, ack in
            self?.questionView?.updateInfo(with: "Next Round!")
        }
        client.socket.on("allWrong") { [weak self] data, ack in
            self?.questionView?.updateInfo(with: "Everybody was wrong...")
        }
        client.socket.on("questionAnswered") { [weak self] data, ack in
            guard let options = self?.questionView?.options, let correctAnswer = self?.question?.correctAnswer, let playerView = self?.playerView else {
                fatalError("properties not available")
            }
            self?.questionView?.options.forEach {$0.isUserInteractionEnabled = false}
            for view in options {
                if view.tag != correctAnswer {
                    view.backgroundColor = UIColor(named: "Orange")
                }
            }
            guard let id = data[0] as? String else {
                fatalError("No id")
            }
            playerView.addPoint(id: id)
            if id == self?.player.id {
                self?.questionView?.updateInfo(with: "Correct! a point for you!")
            } else if let i = self?.players.index(where: { $0.id == id}) {
                if let name = self?.players[i].name {
                    self?.questionView?.updateInfo(with: "\(String(describing: name)) takes the point!")
                }
            }
        }
        client.socket.on("destroyed") { [weak self] data, ack in
            if data[0] as? String == self?.client.channel?["channel"] && self?.isGameOver == false {
                self?.performSegue(withIdentifier: "channelDestroyedPlayer", sender: nil)
            }
        }
        client.socket.on("statusChange") { [weak self] data, ack in
            self?.performSegue(withIdentifier: "lostConnPlayer", sender: nil)
        }
        client.socket.on("announceWinner") { [weak self] data, ack in
            guard let id = data[0] as? String else {
                fatalError("No id")
            }
            var winner = ""
            var message = ""
            if id == self?.player.id {
                winner = "You"
                message = "Congratulations!"
            } else if let i = self?.players.index(where: { $0.id == id}) {
                if let name = self?.players[i].name {
                    winner = name
                    message = "Too bad..."
                }
            }
            let alert = UIAlertController(title: "\(winner) won", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                self?.performSegue(withIdentifier: "gameOverPlayer", sender: nil)
            })
            
            alert.addAction(action)
            self?.present(alert, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
//    MARK: Private Methods
    private func generateTapGesture(number: Int) -> [UITapGestureRecognizer] {
        var recognizers = [UITapGestureRecognizer]()
        for _ in 0..<number {
            recognizers.append(UITapGestureRecognizer(target: self, action: #selector(answerTouch)))
        }
        return recognizers
    }
    
    
    @objc func answerTouch(sender: UITapGestureRecognizer){
        if let guess = sender.view?.tag {
            print(sender)
            client.socket.emit("answer", guess)
        }
    }
}












