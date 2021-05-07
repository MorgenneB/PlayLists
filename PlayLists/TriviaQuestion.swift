//
//  TriviaQuestion.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-16.
//

import Foundation

// Stores the question prompt, its answers, and the index of the correct answer
class TriviaQuestion {
    let question: String;
    let answers: [String];
    let correctAnswer: Int;
    
    init(question: String, answers: [String], correctAnswer: Int) {
        self.question = question;
        self.answers = answers;
        self.correctAnswer = correctAnswer;
    }
    
    func isAnswerCorrect(answer: Int) -> Bool {
        return answer == self.correctAnswer;
    }
    
    func getAnswers() -> [String] {
        return self.answers;
    }
    
    func getQuestion() -> String {
        return self.question;
    }
    
    func getCorrectAnswer() -> Int {
        return self.correctAnswer;
    }
}
