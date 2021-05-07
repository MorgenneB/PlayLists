//
//  TriviaResultsViewController.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-16.
//

import UIKit

class TriviaResultsViewController: UIViewController {
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var bestAttemptLabel: UILabel!
    
    let saveBestCorrectAnswers = "bestCorrectAnswers";
    
    var correctAnswers: Int?
    var bestCorrectAnswers: Int?
    var totalQuestions: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        displayResults();
        getBestResult();
        self.navigationItem.hidesBackButton = true;
    }
    
    func initWithResult(_ correctAnswers: Int, outOf totalQuestions: Int) {
        self.correctAnswers = correctAnswers;
        self.totalQuestions = totalQuestions;
    }
    
    // Shows how well the user did and displays a message of encouragement
    func displayResults() {
        resultsLabel.text = "\(String(correctAnswers!))/\(String(totalQuestions!))";
        if (Double(correctAnswers!) / Double(totalQuestions!) < 0.5) {
            commentLabel.text = "Try again!";
        } else if (Double(correctAnswers!) / Double(totalQuestions!) < 0.75) {
            commentLabel.text = "Good try!";
        } else if (Double(correctAnswers!) / Double(totalQuestions!) < 1.0) {
            commentLabel.text = "Nice work!";
        } else {
            commentLabel.text = "Outstanding!";
        }
    }
    
    // Retrieves the user's best recorded attempt, and updates it if necessary
    func getBestResult() {
        bestCorrectAnswers = UserDefaults.standard.integer(forKey: saveBestCorrectAnswers);
        if (correctAnswers! > bestCorrectAnswers!) {
            UserDefaults.standard.setValue(correctAnswers, forKey: saveBestCorrectAnswers);
            bestCorrectAnswers = correctAnswers;
        }
        bestAttemptLabel.text = "\(String(bestCorrectAnswers!))/\(String(totalQuestions!))";
    }
}
