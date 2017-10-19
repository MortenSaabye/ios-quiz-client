//
//  Question.swift
//  quiz-sockets
//
//  Created by Morten Saabye Kristensen on 15/10/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import Foundation
class Question {
    let questionText: String
    var options = [String]()
    let correctAnswer: Int
    var answered = false
    init(question: String, optionOne: String, optionTwo: String, optionThree: String, optionFour: String, correctAnswer: Int) {
        self.questionText = question
        self.options.append(optionOne)
        self.options.append(optionTwo)
        self.options.append(optionThree)
        self.options.append(optionFour)
        self.correctAnswer = correctAnswer
    }
    
    init(question: String, options: [String], correctAnswer: Int) {
        self.questionText = question
        for option in options {
            self.options.append(option)
        }
        self.correctAnswer = correctAnswer
    }
}
