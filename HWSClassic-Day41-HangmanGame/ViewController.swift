//
//  ViewController.swift
//  Project9-Milestone
//
//  Created by Romain Buewaert on 12/10/2021.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var hangmanImage: UIImageView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var lettersListLabel: UILabel!

    var wordList = [String]()
    var wordToFind = ""
    let lettersAccepted = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    var lettersToFind = [String]()
    var lettersUsed = [String]()
    var remainingProposal = 7
    var score = 0 {
        didSet {
            title = "HANGMAN             Score = \(score)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let wordListURL = Bundle.main.url(forResource: "WordList", withExtension: "txt") {
            if let extractedWord = try? String(contentsOf: wordListURL) {
                wordList = extractedWord.components(separatedBy: "\n")
                wordList.removeLast()
            }
        }

        title = "HANGMAN             Score = \(score)"

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(proposeLetter))

        configureWordView()
    }

    func configureWordView() {
        wordList.shuffle()
        wordToFind = wordList[0]
        wordLabel.text = ""
        lettersListLabel.text = ""
        lettersToFind.removeAll()
        lettersUsed.removeAll()
        remainingProposal = 7
        configureHangmanImage()

        for letter in wordToFind {
            let strLetter = String(letter)
            lettersToFind.append(strLetter)
            wordLabel.text? += "?"
        }
        print("Word to find: \(wordToFind)")
    }

    func replaceLetter(_ letter: String) {
        var currentWord = [String]()
        guard var wordScreen = wordLabel.text else { return }
        for letterDetailed in wordScreen {
            let strLetter = String(letterDetailed)
            currentWord.append(strLetter)
        }
        print("current letters = \(currentWord)")

        for (index, letterDetailed) in wordToFind.enumerated() {
            let strLetter = String(letterDetailed)
            if strLetter == letter {
                currentWord[index] = letter
            }
        }

        wordScreen = ""
        for letterDetailed in currentWord {
            wordScreen += letterDetailed
        }
        print("word screen = \(wordScreen)")
        wordLabel.text = wordScreen

        lettersUsed.append(letter)

        if !wordScreen.contains("?") {
            score += 1
            alertMessageEndOfParty()
        }
    }

    func configureHangmanImage() {
        switch remainingProposal {
        case 0:
            hangmanImage.image = UIImage(named: "imageHangman7")
        case 1:
            hangmanImage.image = UIImage(named: "imageHangman6")
        case 2:
            hangmanImage.image = UIImage(named: "imageHangman5")
        case 3:
            hangmanImage.image = UIImage(named: "imageHangman4")
        case 4:
            hangmanImage.image = UIImage(named: "imageHangman3")
        case 5:
            hangmanImage.image = UIImage(named: "imageHangman2")
        case 6:
            hangmanImage.image = UIImage(named: "imageHangman1")
        case 7:
            hangmanImage.image = UIImage(named: "imageHangman")
        default:
            break
        }
    }

    @objc func proposeLetter() {
        let ac = UIAlertController(title: "Enter a letter", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let action = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            guard let letter = ac?.textFields?[0].text?.uppercased() else { return }
            guard letter.count == 1 else { return }

            guard let lettersAccepted = self?.lettersAccepted else { return }
            guard lettersAccepted.contains(letter) else { return }

            guard let currentWord = self?.wordToFind else { return }
            guard let lettersListLabel = self?.lettersListLabel.text else { return }

            if currentWord.contains(letter) && !lettersListLabel.contains(letter) {
                self?.lettersListLabel.text! += letter
                self?.replaceLetter(letter)
            } else {
                self?.lettersListLabel.text! += letter
                self?.remainingProposal -= 1
                self?.configureHangmanImage()
                if self?.remainingProposal == 0 {
                    self?.alertMessageEndOfParty()
                } else {
                    if lettersListLabel.contains(letter) {
                        self?.alertMessage(title: "Letter already used")
                    } else {
                        self?.alertMessage(title: "Letter not found")
                    }
                }
            }
        }

        ac.addAction(action)
        present(ac, animated: true, completion: nil)
    }

    func alertMessage(title: String) {
        let ac = UIAlertController(title: title, message: "Remaining proposal: \(remainingProposal)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }

    func alertMessageEndOfParty() {
        let ac = UIAlertController(title: "End of Party!", message: "Word to found was \(wordToFind)\nNew word is comming !", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.configureWordView()
        }))
        present(ac, animated: true, completion: nil)
    }
}
