//
//  QuestionView.swift
//  quiz-sockets
//
//  Created by Morten Saabye Kristensen on 17/10/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
class QuestionView {
    let optionsView: UIStackView
    let questionView: UIView
    let infoLabel: UILabel
    var options = [UIView]()
    let context: UIViewController
    init(context: UIViewController, tapGesture: [UITapGestureRecognizer]?) {
        self.optionsView = UIStackView()
        self.questionView = UIView()
        self.infoLabel = UILabel()
        self.context = context
        questionView.layer.cornerRadius = 10
        questionView.backgroundColor = UIColor(named: "Yellow")
        let topGuide = context.view.subviews.last
        context.view.addSubview(questionView)
        questionView.snp.makeConstraints { [unowned context] (make) in
            make.left.right.equalTo(context.view).inset(12)
            make.top.equalTo(topGuide?.snp.bottom ?? context.view.safeAreaLayoutGuide.snp.top).offset(12)
        }
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "A question is going to appear here soon..."
        questionView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(questionView).inset(UIEdgeInsetsMake(8, 8, 8, 8))
        }
        //        Setup options area
        optionsView.axis = .vertical
        context.view.addSubview(optionsView)
        optionsView.snp.makeConstraints { [unowned context] (make) in
            make.left.right.equalTo(context.view).inset(12)
            make.top.equalTo(questionView.snp.bottom).offset(12)
        }
        optionsView.alignment = .fill
        optionsView.distribution = .fillEqually
        optionsView.spacing = 10
        
        let topStack = UIStackView()
        topStack.alignment = .fill
        topStack.distribution = .fillEqually
        topStack.spacing = 10
        optionsView.addArrangedSubview(topStack)
        topStack.axis = .horizontal
        
        let bottomStack = UIStackView()
        bottomStack.alignment = .fill
        bottomStack.distribution = .fillEqually
        bottomStack.spacing = 10
        optionsView.addArrangedSubview(bottomStack)
        bottomStack.axis = .horizontal
        
        let optionOne = makeOptionButton(optionNumber: 1, tapGesture: tapGesture?[safe: 0])
        topStack.addArrangedSubview(optionOne)
        let optionTwo = makeOptionButton(optionNumber: 2, tapGesture: tapGesture?[safe: 1])
        topStack.addArrangedSubview(optionTwo)
        let optionThree = makeOptionButton(optionNumber: 3, tapGesture: tapGesture?[safe: 2])
        bottomStack.addArrangedSubview(optionThree)
        let optionFour = makeOptionButton(optionNumber: 4, tapGesture: tapGesture?[safe: 3])
        bottomStack.addArrangedSubview(optionFour)
        
        infoLabel.textAlignment = .center
        infoLabel.font = UIFont.boldSystemFont(ofSize: 22)
        infoLabel.numberOfLines = 0
        context.view.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(bottomStack.snp.bottom).offset(20)
            make.left.right.equalTo(context.view).inset(12)
        }
    }
    
    func updateQuestionBox(question: Question){
        if let label = questionView.subviews.first as? UILabel {
            label.text = question.questionText
        }
        if let optionOne = optionsView.subviews[0].subviews.first{
            optionOne.backgroundColor = UIColor(named: "Blue")
            updateOptionText(button: optionOne, text: question.options[0], number: 1)
        }
        if let optionTwo = optionsView.subviews[0].subviews.last {
            optionTwo.backgroundColor = UIColor(named: "Blue")
            updateOptionText(button: optionTwo, text: question.options[1], number: 2)
        }
        if let optionThree = optionsView.subviews[1].subviews.first {
            optionThree.backgroundColor = UIColor(named: "Blue")
            updateOptionText(button: optionThree, text: question.options[2], number: 3)
        }
        if let optionFour = optionsView.subviews[1].subviews.last {
            optionFour.backgroundColor = UIColor(named: "Blue")
            updateOptionText(button: optionFour, text: question.options[3], number: 4)
        }
    }
    func makeOptionButton(optionNumber: Int, tapGesture: UITapGestureRecognizer?) -> UIView {
        let button = UIView()
        button.backgroundColor = UIColor(named: "Blue")
        button.tag = optionNumber
        button.layer.cornerRadius = 10
        if let tap = tapGesture {
            button.addGestureRecognizer(tap)
        }
        let label = UILabel()
        label.text = " "
        label.textColor = .white
        label.numberOfLines = 0
        button.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(button).inset(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        }
        self.options.append(button)
        return button
    }
    
    func updateInfo(with text: String) {
        self.infoLabel.text = text
    }
    
    private func updateOptionText(button: UIView, text: String, number: Int) {
        if let label = button.subviews.first as? UILabel {
            label.text = "\(number): \(text)"
        }
    }
    
    
}
