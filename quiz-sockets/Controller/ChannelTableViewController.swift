//
//  ChannelTableViewController.swift
//  quiz-sockets
//
//  Created by Morten Saabye Kristensen on 10/10/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import UIKit
import SocketIO

class ChannelTableViewController: UITableViewController {
    let socket = SocketIOClient(socketURL: URL(string: "http://localhost:3000")!)
    var channels = [[String:String]]()
    var name: String?

    var unwinding = false
    var destroyed = false
    var gameOver = false
    var lostConn = false
    @IBOutlet weak var addButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        addHandlers()
        socket.connect()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if unwinding {
            var title = ""
            var message = ""
            if gameOver {
                title = "Try again"
                message = "Pick or create a new channel"
                gameOver = false
            } else if destroyed {
                title = "Channel was closed"
                message = "It looks like the moderator left"
                destroyed = false
            } else if lostConn {
                title = "Lost connection"
                message = "Looks like you lost connection from the server. Trying to reconnect."
                lostConn = false
            }
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.socket.emit("restart")
                self.unwinding = false
            })
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return channels.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath) as? ChannelTableViewCell else {
            fatalError("Could not cast cell as ChannelTableViewCell")
        }
        cell.ChannelLabel.text = channels[indexPath.row]["channel"]
        cell.moderatorNameLabel.text = channels[indexPath.row]["name"]
        return cell
    }
    
    //    MARK: tableView methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if channels.count >= indexPath.row {
            performSegue(withIdentifier: "joinedChannel", sender: indexPath)
        }
    }

    func addHandlers(){
        socket.on("succes") {[weak self] data, ack in
            let alert = UIAlertController(title: "You have been connected!", message: "Select a player name", preferredStyle: .alert)
            let nameAction = UIAlertAction(title: "Set name", style: .default, handler: { (action) in
                self?.name = alert.textFields![0].text
                self?.socket.emit("join", with: [self?.name as Any])
                self?.addButton.isEnabled = true
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
            
            alert.addTextField(configurationHandler: { (nameText) in
                nameText.placeholder = "Enter your name"
            })
            alert.addAction(nameAction)
            alert.addAction(cancelAction)
            self?.present(alert, animated: true, completion: nil)
        }
        
        socket.on("selectChannel") { [weak self] data, ack in
            if let channels = data[0] as? [[String:String]] {
                self?.channels = channels
                self?.tableView.reloadData()
            }
        }
        socket.on("newChannel") { [weak self] data, ack in
            if let newChannel = data[0] as? [String:String] {
                self?.channels.append(newChannel)
                self?.tableView.reloadData()
            }
        }
        socket.on("destroyed") { [weak self] data, ack in
            if let channel = data[0] as? [String:String], let index = self?.channels.index(where: {$0 == channel}) {
                self?.channels.remove(at: index)
                self?.tableView.reloadData()
            }
        }
        
        socket.onAny { (data) in
            let defaultValue = ["nothing"]
            print("got event: \(data.event) with: \(data.items ?? defaultValue))")
        
        }
    }
    // MARK: Actions
    
    @IBAction func addChannelAction(_ sender: Any) {
        let alert = UIAlertController(title: "Create a new channel", message: "Select a channel name", preferredStyle: .alert)
        let nameAction = UIAlertAction(title: "Set name", style: .default, handler: { [unowned self] (action) in
            if let channelName = alert.textFields![0].text, let name = self.name {
                let channel = ["channel":channelName,"name":name]
                self.channels.append(channel)
                self.tableView.reloadData()
                self.performSegue(withIdentifier: "createdChannel", sender: channel)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addTextField(configurationHandler: { (nameText) in
            nameText.placeholder = "Enter the channel name"
        })
        alert.addAction(nameAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? WaitingViewController else {
            fatalError("Can't cast destination to WaitingViewController")
        }
        
        if segue.identifier == "joinedChannel" {
            guard let indexPath = sender as? IndexPath else {
                print("No indexPath")
                return
            }
            destination.client = Client(socket: self.socket, channel: self.channels[indexPath.row])
        }
        if segue.identifier == "createdChannel" {
            guard let channel = sender as? [String:String] else {
                fatalError("No channel")
            }
            destination.client = Client(socket: self.socket, channel: channel)
        }
    }
    
    @IBAction func unwindFromDestroyed(segue: UIStoryboardSegue) {
        self.destroyed = true
        self.unwinding = true
    }
    @IBAction func unwindFromLostConn(segue: UIStoryboardSegue) {
        self.lostConn = true
        self.unwinding = true
    }
    @IBAction func unwindFromGameOver(segue: UIStoryboardSegue) {
        self.gameOver = true
        self.unwinding = true
    }
}
