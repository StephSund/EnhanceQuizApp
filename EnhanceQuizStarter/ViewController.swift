//
//  ViewController.swift
//  EnhanceQuizStarter
//
//  Created by Pasan Premaratne on 3/12/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

import UIKit
import GameKit
import AudioToolbox

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    var questionsPerRound = 0
    var questionsAsked = 0
    var correctQuestions = 0
    var indexOfSelectedQuestion = 0
    var alreadyUsedNumbersInRandomQuestion = [Int]()  // To prevent repating questions


    var gameSound: SystemSoundID = 0
    var wrongSound: SystemSoundID = 0
    var correctSound: SystemSoundID = 0
   
    // Data
    let questionAndAnswerRepository = questionAndAnswerRepo().questionsAndAnswerRepository
    
   
    // MARK: - Outlets
    
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var answ1Button: UIButton!
    @IBOutlet weak var answ2button: UIButton!
    @IBOutlet weak var answ3button: UIButton!
    @IBOutlet weak var answ4button: UIButton!
    @IBOutlet weak var timeLimitLabel: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSounds()
        playSound(sound: gameSound)
        displayQuestion()
        
        timeLimitLabel.text = "Time limit:\(15)"
        questionsPerRound = questionAndAnswerRepository.count
    }
    
    // MARK: - Helpers
    
    // Loading sounds [Start, Wrong answer, Correct answer]
    func loadSounds() {
        let path = Bundle.main.path(forResource: "GameSound", ofType: "wav")
        let soundUrl = URL(fileURLWithPath: path!)
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &gameSound)
        
        let path1 = Bundle.main.path(forResource: "correct", ofType: "wav")
        let soundUrl1 = URL(fileURLWithPath: path1!)
        AudioServicesCreateSystemSoundID(soundUrl1 as CFURL, &correctSound)
        
        let path2 = Bundle.main.path(forResource: "wrong", ofType: "wav")
        let soundUrl2 = URL(fileURLWithPath: path2!)
        AudioServicesCreateSystemSoundID(soundUrl2 as CFURL, &wrongSound)
        
    }
    
    
    func playSound(sound:SystemSoundID) {
         AudioServicesPlaySystemSound(sound)
    }
    
    

    
    
    
    
    // Timer Function (Lightning round 15 seconds)
    
    var timerCountDown:Timer!
    var totalTime = 15
    
    func initiateTimer() {
        timerCountDown = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateMyTime), userInfo: nil, repeats: true)
    }
    
    
    @objc func updateMyTime() {
        timeLimitLabel.text = "Time limit:\(totalTime)"
        
        if totalTime != 0 {
            totalTime -= 1
        } else {
            timerCountDown.invalidate()
            playSound(sound: wrongSound)
            questionField.text = "Too slow"
            
            let correctAnswer = questionAndAnswerRepository[indexOfSelectedQuestion].correctOption
            
            switch correctAnswer {
            case 1: answ1Button.tintColor = UIColor.green
            case 2: answ2button.tintColor = UIColor.green
            case 3: answ3button.tintColor = UIColor.green
            case 4: answ4button.tintColor = UIColor.green
            default: print("Error with tags")
            }
            
            questionsAsked += 1
            
            buttonInterraction(enabled: false)
            
            loadNextRound(delay: 2)
            
        }
    }
    
    
    
    
    // Generating a random number
    func generateRandomNumber(upperBound:Int) -> Int {
        return GKRandomSource.sharedRandom().nextInt(upperBound: upperBound)
    }
    
    
    func displayQuestion() {
       
        indexOfSelectedQuestion = generateRandomNumber(upperBound: questionAndAnswerRepository.count)
       
        // To make sure there are no repeating questions
        if alreadyUsedNumbersInRandomQuestion.contains(indexOfSelectedQuestion) {
            displayQuestion()
            return
        }
        
        // Reseting the timer for the next round
        totalTime = 15 // set to 15 seconds
        initiateTimer()
       
        let questionDictionary = questionAndAnswerRepository[indexOfSelectedQuestion]
        alreadyUsedNumbersInRandomQuestion.append(indexOfSelectedQuestion)
        questionField.text = questionDictionary.question
        buttonInterraction(enabled: true)
        answ4button.isHidden = false
        
        
        if questionDictionary.fourthOption == nil  {
           print("There is no fourh option, repostion elements")
            answ1Button.setTitle(questionDictionary.firstOption, for: .normal)
            answ2button.setTitle(questionDictionary.secondOption, for: .normal)
            answ3button.setTitle(questionDictionary.thirdOptoin, for: .normal)
            answ4button.isHidden = true // Since the buttons are put in a vertical stack view,  hiding the 4 button will result in automatic repositioning of the buttons [Exceeds expectation criteria]
      
        } else {
            print("All four options present")
            answ1Button.setTitle(questionDictionary.firstOption, for: .normal)
            answ2button.setTitle(questionDictionary.secondOption, for: .normal)
            answ3button.setTitle(questionDictionary.thirdOptoin, for: .normal)
            answ4button.setTitle(questionDictionary.fourthOption, for: .normal)
        }
        
        playAgainButton.isHidden = true
        
    }
    
    func displayScore() {
        // Hide the answer buttons
        answ1Button.isHidden = true
        answ2button.isHidden = true
        answ3button.isHidden = true
        answ4button.isHidden = true
        timeLimitLabel.isHidden = true
        
        // Display play again button
        playAgainButton.isHidden = false
        
        // Showing score
        questionField.text = "Way to go!\nYou got \(correctQuestions) out of \(questionsPerRound) correct!"
    }
    
    func nextRound() {
        if questionsAsked == questionsPerRound {
            // Game is over
            displayScore()
        } else {
            // Continue game
             answ1Button.tintColor = UIColor.white
             answ2button.tintColor = UIColor.white
             answ3button.tintColor = UIColor.white
             answ4button.tintColor = UIColor.white
            
             displayQuestion()
        }
    }
    
    
    
    func loadNextRound(delay seconds: Int) {
        // Converts a delay in seconds to nanoseconds as signed 64 bit integer
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        // Calculates a time value to execute the method given current time and delay
        let dispatchTime = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)
        
        // Executes the nextRound method at the dispatch time on the main queue
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.nextRound()
        }
    }
    
   
    
    
    // MARK: - Actions
    
    @IBAction func checkAnswer(_ sender: UIButton) {
        // Increment the questions asked counter
        questionsAsked += 1
        
        // Stops the timer
        timerCountDown.invalidate()
        timeLimitLabel.text = "Time limit:\(15)"
        
        let selectedQuestionDict = questionAndAnswerRepository[indexOfSelectedQuestion]
        let correctAnswer = selectedQuestionDict.correctOption
        
        buttonInterraction(enabled: false)
        
        // If Correct answer
        if sender.tag == correctAnswer {
            correctQuestions += 1
            questionField.text = "Correct!"
            
            playSound(sound: correctSound)
            
            switch sender.tag {
            case 1: answ1Button.tintColor = UIColor.green
            case 2: answ2button.tintColor = UIColor.green
            case 3: answ3button.tintColor = UIColor.green
            case 4: answ4button.tintColor = UIColor.green
            default: print("Error with tags")
            }
            
            
            
        } else {  // If Wrong answer
            questionField.text = "Sorry, wrong answer!"
            
            playSound(sound: wrongSound)
            
            // Displaying your wrong guess in red
            switch sender.tag {
            case 1: answ1Button.tintColor = UIColor.red
            case 2: answ2button.tintColor = UIColor.red
            case 3: answ3button.tintColor = UIColor.red
            case 4: answ4button.tintColor = UIColor.red
            default: print("Error with tags")
            }
            
            // Showing the right answer in green text
            switch correctAnswer {
            case 1: answ1Button.tintColor = UIColor.green
            case 2: answ2button.tintColor = UIColor.green
            case 3: answ3button.tintColor = UIColor.green
            case 4: answ4button.tintColor = UIColor.green
            default: print("Error")
            }
            
            
    }
        loadNextRound(delay: 2)
       
    }
    
    
    @IBAction func playAgain(_ sender: UIButton) {
      
        // Show the answer buttons
        answ1Button.isHidden = false
        answ2button.isHidden = false
        answ3button.isHidden = false
        answ4button.isHidden = false
        timeLimitLabel.isHidden = false
        
        // Nullifying all variables and restarting the quiz
        questionsAsked = 0
        correctQuestions = 0
        alreadyUsedNumbersInRandomQuestion = [Int]()
        indexOfSelectedQuestion = 0
        
        nextRound()
        
        
    }
    
    
    
    // Make buttons unclickable
    func buttonInterraction(enabled:Bool) {
        answ1Button.isUserInteractionEnabled = enabled
        answ2button.isUserInteractionEnabled = enabled
        answ3button.isUserInteractionEnabled = enabled
        answ4button.isUserInteractionEnabled = enabled
    }
    
    
   

    
    
    

}







