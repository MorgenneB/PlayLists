//
//  TriviaGameViewController.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-16.
//

import UIKit

enum TRIVIA_QUESTION_TYPES: CaseIterable {
    case releaseDate;
    case gameGenre;
    case gamePlatform;
}

class TriviaGameViewController: UIViewController {
    @IBOutlet weak var triviaQuestionView: UIStackView!
    @IBOutlet weak var currentQuestionTitle: UILabel!
    @IBOutlet weak var questionText: UITextView!
    @IBOutlet weak var answerButtonOne: UIButton!
    @IBOutlet weak var answerButtonTwo: UIButton!
    @IBOutlet weak var answerButtonThree: UIButton!
    @IBOutlet weak var answerButtonFour: UIButton!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    var answerButtons = [UIButton]();
    let initializingDataView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 200, height: 200));
    
    let triviaResultsSegueID = "TriviaResults";
    let quitTriviaSegueID = "QuitTrivia";

    // Trivia variables
    
    var timer: Timer?;
    // In seconds: generate random dates no more/less than 5 years from a given date
    let MIN_MAX_DATE_INTERVAL = (60 * 60 * 24 * 365 * 5);
    let SECONDS_TO_ANSWER = 20
    let TOTAL_QUESTIONS = 10;
    let ANSWERS_PER_QUESTION = 4;
    var questionTypesGenerated: [TRIVIA_QUESTION_TYPES:[String]] = [:];
    var triviaQuestions = [TriviaQuestion]();
    var currentQuestion = 0;
    var correctAnswers = 0;
    var isValidatingAnswer = false;
    
    // Required data for trivia
    var genreList = [GenreData]();
    var platformList = [PlatformData]();
    var gamesList = [Game]();
    var setupQueue = DispatchQueue(label: "setupGame");
    var setupGroup = DispatchGroup();

    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide Trivia view until all data has been loaded
        triviaQuestionView.isHidden = true;
        initializingDataView.center = self.view.center;
        initializingDataView.style = .large;
        displayActivityIndicator();
        // Setup references to answer buttons
        answerButtons = [
            answerButtonOne,
            answerButtonTwo,
            answerButtonThree,
            answerButtonFour
        ];
        for button in answerButtons {
            button.setTitleColor(UIColor.black, for: .disabled)
        }
        // Credit to https://medium.com/swiftcraft/how-to-perform-an-action-after-two-asynchronous-functions-finish-1d796faf5daf
        // for help understanding the DispatchGroup
        self.setupGroup.enter();
        self.setupGroup.enter();
        setupQueue.async {
            IGDBAPI.igdbAPI.getGenreList(handleCompletion: self.setGenreList(_:))
            IGDBAPI.igdbAPI.getPlatformList(handleCompletion: self.setPlatformList(_:));
        }
        setupGroup.notify(queue: setupQueue, execute: {
            DispatchQueue.main.async {
                self.prepareTriviaQuestions();
                self.triviaQuestionView.isHidden = false;
                self.hideActivityIndicator();
                self.displayTriviaQuestion();
            }
        })
    }
    
    // MARK: Activity Indicator
    
    func displayActivityIndicator() {
        self.view.addSubview(initializingDataView);
        initializingDataView.startAnimating();
    }
    
    func hideActivityIndicator() {
        initializingDataView.removeFromSuperview();
    }
    
    // MARK: Get Required Data
    func setGenreList(_ genreList: [GenreData]) {
        self.genreList = genreList;
        self.setupGroup.leave();
    }
    
    func setPlatformList(_ platformList: [PlatformData]) {
        self.platformList = platformList;
        self.setupGroup.leave();
    }
    
    // MARK: Create Trivia Questions
    
    func prepareTriviaQuestions() {
        gamesList = GameDictionary.sharedPlaylists.getAllGames();
        var i = 0;
        while i < TOTAL_QUESTIONS {
            if let question = generateTriviaQuestion() {
                triviaQuestions.append(question);
                i += 1;
            }
        }
    }
    
    // Function to randomly generate unique trivia questions
    // Will return nil if it attempts to generate a question that already exists
    func generateTriviaQuestion() -> TriviaQuestion? {
        var question: TriviaQuestion?;
        let questionTypeToGenerate = TRIVIA_QUESTION_TYPES.allCases.randomElement();
        let index = Int.random(in: 0..<gamesList.count);
        let gameToGenerateQuestionFor = gamesList[index];
        if let generatedForGames = questionTypesGenerated[questionTypeToGenerate!] {
            if generatedForGames.contains(gameToGenerateQuestionFor.getName()) {
                return nil
            }
        } else {
            questionTypesGenerated[questionTypeToGenerate!] = [String]();
        }
        switch questionTypeToGenerate {
            case .releaseDate:
                question = generateReleaseDateQuestion(forGame: gameToGenerateQuestionFor);
            case  .gamePlatform:
                question = generatePlatformQuestion(forGame: gameToGenerateQuestionFor);
            case .gameGenre:
                question = generateGenreQuestion(forGame: gameToGenerateQuestionFor);
            default:
                return nil;
        }
        questionTypesGenerated[questionTypeToGenerate!]!.append(gameToGenerateQuestionFor.getName())
        return question;
    }
    
    func generateReleaseDateQuestion(forGame game: Game) -> TriviaQuestion? {
        if game.getReleaseDate() == nil {
            return nil;
        }
        let questionPrompt = "What was the initial release date of \(game.getName())?";
        var minRandomDate = game.getReleaseDate()! - MIN_MAX_DATE_INTERVAL;
        var maxRandomDate = game.getReleaseDate()! + MIN_MAX_DATE_INTERVAL;
        // Ensure min date is not negative
        if (minRandomDate < 0) {
            minRandomDate = 0;
        }
        // Ensure max date does not exceed the current date
        if (maxRandomDate > Int(Date().timeIntervalSince1970)) {
            maxRandomDate = Int(Date().timeIntervalSince1970);
        }
        let correctAnswer = game.getFormattedReleaseDate();
        let correctAnswerIndex = Int.random(in: 0..<ANSWERS_PER_QUESTION);
        var answers = [String]();
        for i in 0..<ANSWERS_PER_QUESTION {
            if (i == correctAnswerIndex) {
                answers.append(correctAnswer);
            } else {
                let randomDate = Int.random(in: minRandomDate...maxRandomDate);
                answers.append(getFormattedDate(randomDate))
            }
        }
        return TriviaQuestion(question: questionPrompt, answers: answers, correctAnswer: correctAnswerIndex)
    }
    
    func generatePlatformQuestion(forGame game: Game ) -> TriviaQuestion? {
        if game.getPlatforms() == nil {
            return nil;
        }
        let questionPrompt = "On which of these platforms did \(game.getName()) release on (initial release or port)?";
        let platformIndex = Int.random(in: 0..<game.getPlatforms()!.count);
        let correctAnswer = self.platformList.first(where: { $0.getId() == game.getPlatforms()![platformIndex] })?.getName();
        let correctAnswerIndex = Int.random(in: 0..<ANSWERS_PER_QUESTION);
        var answers = [String]();
        var i = 0;
        while i < ANSWERS_PER_QUESTION {
            if (i == correctAnswerIndex) {
                answers.append(correctAnswer!);
                i += 1;
            } else {
                let randomPlatformIndex = Int.random(in: 0..<platformList.count);
                let randomPlatform = platformList[randomPlatformIndex];
                if (!game.getPlatforms()!.contains(randomPlatform.getId()) && !answers.contains(randomPlatform.getName())) {
                    answers.append(randomPlatform.getName());
                    i += 1;
                }
            }
        }
        return TriviaQuestion(question: questionPrompt, answers: answers, correctAnswer: correctAnswerIndex)
    }
    
    func generateGenreQuestion(forGame game: Game) -> TriviaQuestion? {
        if game.getGenres() == nil {
            return nil;
        }
        let questionPrompt = "To which genre does \(game.getName()) belong to?";
        let genreIndex = Int.random(in: 0..<game.getGenres()!.count);
        let correctAnswer = self.genreList.first(where: { $0.getId() == game.getGenres()![genreIndex] })?.getName();
        let correctAnswerIndex = Int.random(in: 0..<ANSWERS_PER_QUESTION);
        var answers = [String]();
        var i = 0;
        while i < ANSWERS_PER_QUESTION {
            if (i == correctAnswerIndex) {
                answers.append(correctAnswer!);
                i += 1;
            } else {
                let randomGenreIndex = Int.random(in: 0..<genreList.count);
                let randomGenre = genreList[randomGenreIndex];
                if (!game.getGenres()!.contains(randomGenre.getId()) && !answers.contains(randomGenre.getName())) {
                    answers.append(randomGenre.getName());
                    i += 1;
                }
            }
        }
        return TriviaQuestion(question: questionPrompt, answers: answers, correctAnswer: correctAnswerIndex)
    }
    
    // Returns date in a human-readable format
    func getFormattedDate(_ date: Int) -> String {
        let dateFormatter = DateFormatter();
        dateFormatter.dateStyle = .medium;
        dateFormatter.timeStyle = .none;
        dateFormatter.locale = Locale(identifier: "en-CA");
        let releaseDate = Date(timeIntervalSince1970: TimeInterval(date))
        let formattedReleaseDate = dateFormatter.string(from: releaseDate);
        return formattedReleaseDate;
    }
    
    func displayTriviaQuestion() {
        if (currentQuestion < TOTAL_QUESTIONS) {
            currentQuestionTitle.text = "Question \(currentQuestion+1) of \(TOTAL_QUESTIONS)"
            let question = triviaQuestions[currentQuestion];
            questionText.text = question.getQuestion();
            let answers = question.getAnswers();
            for i in 0...3 {
                answerButtons[i].setTitle(answers[i], for: .normal);
            }
            timeRemainingLabel.text = "\(String(SECONDS_TO_ANSWER))..."
            startTimer();
        } else {
            // No more questions, take the user to the Results screen
            performSegue(withIdentifier: triviaResultsSegueID, sender: nil);
        }
    }
    
    // Counts down the time remaining for the user to choose an answer
    func startTimer() {
        var secondsRemaining = self.SECONDS_TO_ANSWER + 1;
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                secondsRemaining -= 1;
                self.timeRemainingLabel.text = "\(String(secondsRemaining))..."
                if (secondsRemaining <= 0) {
                    timer.invalidate();
                    self.validateAnswer(selectedAnswer: -1);
                }
            }
            timer?.fire();
    }
    
    // If user quits the trivia game, ensure timer does not continue running
    @IBAction func quit() {
        timer?.invalidate();
        performSegue(withIdentifier: quitTriviaSegueID, sender: nil);
    }
    
    // Validate the answer (or lack thereof) selected by the user
    func validateAnswer(selectedAnswer: Int) {
        isValidatingAnswer = true;
        timer?.invalidate();
        for button in answerButtons {
            button.isEnabled = false;
            
        }
        currentQuestionTitle.text = "Tap to Continue";
        if (selectedAnswer >= 0) {
            // Show that the user picked the correct answer
            if (triviaQuestions[currentQuestion].isAnswerCorrect(answer: selectedAnswer)) {
                correctAnswers += 1;
                answerButtons[selectedAnswer].backgroundColor = .green;
            }
            // Show that the user picked an incorrect answer + show the correct answer
            else {
                answerButtons[selectedAnswer].backgroundColor = .red;
                let correctIndex = triviaQuestions[currentQuestion].getCorrectAnswer();
                answerButtons[correctIndex].backgroundColor = .green;

            }
        }
        // User did not select an answer, show the correct answer
        else {
            let correctIndex = triviaQuestions[currentQuestion].getCorrectAnswer();
            answerButtons[correctIndex].backgroundColor = .green;
        }
    }
    
    // Move on to the next trivia question on screen tap
    @IBAction func continueGame(_ sender: UIGestureRecognizer) {
        if (isValidatingAnswer) {
            isValidatingAnswer = false;
            currentQuestion += 1;
            for button in answerButtons {
                button.isEnabled = true;
                button.backgroundColor = .none;
            }
            displayTriviaQuestion();
        }
    }
    
    @IBAction func answerSelected(_ sender: Any) {
        let answerSelected = answerButtons.firstIndex(of: sender as! UIButton) ?? -1;
        validateAnswer(selectedAnswer: answerSelected);
    }
    
    // Send the user's final results to the TriviaResultsViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == triviaResultsSegueID) {
            let displayVC = segue.destination as! TriviaResultsViewController;
            displayVC.initWithResult(correctAnswers, outOf: TOTAL_QUESTIONS);
        }
    }

}
