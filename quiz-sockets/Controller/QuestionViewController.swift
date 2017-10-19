//
//  QuestionViewController.swift
//  quiz-sockets
//
//  Created by Morten Saabye Kristensen on 12/10/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import UIKit
class QuestionViewController: UIViewController {
    var switches = [UISwitch]()
    var options = [UITextField]()
    var correctAnswer = 1
    @IBOutlet weak var questionTextField: UITextField!
    
    @IBOutlet weak var optionOneTextField: UITextField!
    @IBOutlet weak var optionOneSwitch: UISwitch!
    
    
    @IBOutlet weak var optionTwoTextField: UITextField!
    @IBOutlet weak var optionTwoSwitch: UISwitch!
    
    @IBOutlet weak var optionThreeTextField: UITextField!
    @IBOutlet weak var optionThreeSwitch: UISwitch!
    
    
    @IBOutlet weak var optionFourTextField: UITextField!
    @IBOutlet weak var optionFourSwitch: UISwitch!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubmit()
        setupSwitches()
        setupOptions()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? ModeraterViewController else {
            fatalError("Could not cast destination as ModeratorViewController")
        }
        if let question = questionTextField.text,
        let optionOne = optionOneTextField.text,
        let optionTwo = optionTwoTextField.text,
        let optionThree = optionThreeTextField.text,
        let optionFour = optionFourTextField.text {
            destination.question = Question(question: question, optionOne: optionOne, optionTwo: optionTwo, optionThree: optionThree, optionFour: optionFour, correctAnswer: self.correctAnswer)
        }
    }
    
//    MARK: Private methods
    private func setupSwitches() {
        switches.append(optionOneSwitch)
        switches.append(optionTwoSwitch)
        switches.append(optionThreeSwitch)
        switches.append(optionFourSwitch)
        for ctrl in switches {
            ctrl.addTarget(self, action: #selector(handleSwitch), for: .valueChanged)
        }
    }
    
    private func setupOptions() {
        options.append(optionOneTextField)
        options.append(optionTwoTextField)
        options.append(optionThreeTextField)
        options.append(optionFourTextField)
    }
    
    @objc private func handleSwitch(tappedSwitch: UISwitch) {
        for ctrl in switches {
            ctrl.setOn(false, animated: true)
        }
        tappedSwitch.setOn(true, animated: true)
        for field in options {
            field.backgroundColor = .white
        }
        tappedSwitch.superview?
            .subviews
            .forEach({ (view) in
                if let textField = view as? UITextField {
                    textField.backgroundColor = UIColor(named: "AlphaGreen")
                }
            })
        if let index = switches.index(of: tappedSwitch) {
            correctAnswer = index + 1
        }
    }
    
    fileprivate func setupSubmit() {
        submitBtn.setTitleColor(.white, for: .normal)
        submitBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        submitBtn.layer.cornerRadius = 10
    }

}
