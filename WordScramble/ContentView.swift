//
//  ContentView.swift
//  WordScramble
//
//  Created by Lupu George on 02.08.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords: [String] = []
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    var body: some View {
        
        VStack {
            NavigationView {
                List {
                    HStack {
                        Section {
                            TextField("Enter your word", text: $newWord)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }
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
                
                .navigationBarTitle(rootWord)
                .onSubmit(addNewWord)
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError) {
                    Button("Ok", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
                
            }
            
                
            Button() {
                startGame()
            } label: {
                Text("New Word").frame(maxWidth: .infinity, alignment: .center)
            }
            .buttonStyle(.bordered)
            .fontWeight(.bold)
            .tint(.pink)
            .padding()
            .font(.system(size: 18))
        }
            }
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Think of another")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word is not possible", message: "Use letters that appear in root word!")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word is not real", message: "Think of an existing word.")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
            newWord = ""
        }
    }
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start",
                                               withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
           
        fatalError("Could not load start.txt from bundle.")
    }
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
