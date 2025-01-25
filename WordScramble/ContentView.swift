//
//  ContentView.swift
//  WordScramble
//
//  Created by Francisco Manuel Gallegos Luque on 20/01/2025.
//

import SwiftUI

//struct ContentView: View {
//    let people = ["Finn", "Leia", "Luke"]
//    var body: some View {
//        List(people, id: \.self) {
//            Text($0)
//        }
//    }
//    
//    func testBundles() {
//        if let fileURL = Bundle.main.url(forResource: "some-file", withExtension: "txt") {
//            if let fileContents = try?  String(contentsOf: fileURL) {
//                
//            }
//        }
//    }
//}

//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Text("hola")
//        }
//    }
//    
//    func testStrings() {
//        let input = "a b c"
//        let letters = input.components(separatedBy: " ")
//        let letter = letters.randomElement()
//        let trimmed = letter?.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        let word = "swift"
//        let checker = UITextChecker()
//        
//        
//        let range = NSRange(location: 0, length: word.utf16.count)
//        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
//        
//        let allGood = misspelledRange.location == NSNotFound
//    }
//}

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var playerScore = 0
    
    @State var countDownTimer = 60
    @State var timerRunning = true
    let timer = Timer.publish(every: 1, on: .main, in:. common).autoconnect()
    
    var body: some View {
        NavigationStack {
                List {
                    Section {
                        TextField("Enter your word", text: $newWord)
                            .textInputAutocapitalization(.never)
                    }
                    Section {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                    }
                }
                .navigationTitle(rootWord)
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button("New Game", action: startGame)
                    }
                }
                .onSubmit(addNewWord)
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError) {
                    //                Button("OK") { } //si no agrego nada, pone OK
                } message: {
                    Text(errorMessage)
                }
            Text("Score: \(playerScore)")
            Text("Time: \(countDownTimer)")
                .onReceive(timer) { _ in
                    if countDownTimer > 0 && timerRunning {
                        countDownTimer -= 1
                    } else {
                        timerRunning = false
                        startGame()
                    }
                }
            }

    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isLongEnough(word: answer) else {
            wordError(title: "Word too short", message: "More than 3 letters, please!")
            return
        }
        
        guard isNotSameWord(word: answer) else {
            wordError(title: "Same word", message: "You can't use the same word")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        playerScore += (10 + newWord.count)
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL, encoding: .utf8) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords = [String]()
                playerScore = 0
                countDownTimer = 60
                timerRunning = true
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isNotSameWord(word: String) -> Bool {
        rootWord != word
    }
    
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isLongEnough (word: String) -> Bool {
        word.count >= 3
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

//struct ContentView: View {
//    let people =  [2, 2, 6, 8, 10]
//
//    var body: some View {
//        ForEach(people,  id: \.self) {
//            Text("\($0)")
//        }
//    }
//}

#Preview {
    ContentView()
}


