//
//  ModeraterViewController.swift
//  quiz-sockets
//
//  Created by Morten Saabye Kristensen on 11/10/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import UIKit
import SnapKit
import SocketIO
class ModeraterViewController: UIViewController  {
    
    var client: Client!
    var player: Player!
    var players: [Player]!
    var question: Question?
    var playerView: PlayerView?
    var questionView: QuestionView?
    var pointsToWin: Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Moderator"
        if let pointsToWin = self.pointsToWin {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Target: \(pointsToWin)", style: .plain, target: nil, action: nil)
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        createAskButton()
        questionView = QuestionView(context: self, tapGesture: nil)
        playerView = PlayerView(context: self, players: players)
        
        addHandlers()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addHandlers() {
        client.socket.on("questionAnswered") { [weak self] data, ack in
            guard let playerView = self?.playerView else {
                fatalError("No playerView")
            }
            guard let id = data[0] as? String else {
                fatalError("No id")
            }
            if let i = self?.players.index(where: { $0.id == id}) {
                playerView.addPoint(id: id)
                if let name = self?.players[i].name {
                    self?.questionView?.updateInfo(with: "\(String(describing: name)) takes the point!")
                }
            }
        }
        client.socket.on("allWrong") { [weak self] data, ack in
            self?.questionView?.updateInfo(with: "Everybody was wrong...")
        }
        client.socket.on("question") { [weak self] data, ack in
            guard let questionText = data[0] as? String, let options = data[1] as? [String], let correctAnswer = data[2] as? Int, let questionView = self?.questionView else {
                fatalError("Could not find correct data in question.")
            }
            let question = Question(question: questionText, options: options, correctAnswer: correctAnswer)
            self?.question = question
            questionView.updateQuestionBox(question: question)
        }
        client.socket.on("announceWinner") { [weak self] data, ack in
            guard let id = data[0] as? String else {
                fatalError("No id")
            }
            var winner = ""
            if let i = self?.players.index(where: { $0.id == id}) {
                if let name = self?.players[i].name {
                    winner = name
                }
            }
            let alert = UIAlertController(title: "\(winner) wins!", message: "You did great!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                self?.performSegue(withIdentifier: "gameOverModerator", sender: nil)
            })

            alert.addAction(action)
            self?.present(alert, animated: true, completion: nil)
        }
        client.socket.on("statusChange") { [weak self] data, ack in
            self?.performSegue(withIdentifier: "lostConnModerator", sender: nil)
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
    @IBAction func unwindFromQuestion(segue: UIStoryboardSegue) {
        guard let question = self.question else {
            fatalError("No question found")
        }
        client.socket.emit("question", question.questionText, question.options, question.correctAnswer)
    }
//    MARK: Private methods
    private func createAskButton() {
        let button = UIButton()
        button.setTitle("Ask a question", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.titleLabel?.textColor = .white
        button.backgroundColor = UIColor(named: "Green")
        button.layer.cornerRadius = 10
        view.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(12)
            make.height.equalTo(40)
            make.right.equalTo(self.view).offset(-12)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(12)
        }
        button.addTarget(self, action: #selector(askQuestion), for: .touchUpInside)
    }
    
    @objc private func askQuestion() {
        if self.question != nil {
            self.client.socket.emit("nextRound")
        }
        self.questionView?.updateInfo(with: "")
        performSegue(withIdentifier: "AskQuestionSegue", sender: nil)
    }
}
