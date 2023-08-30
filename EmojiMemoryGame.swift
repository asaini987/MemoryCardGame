import SwiftUI

class EmojiMemoryGame: ObservableObject { //causes viewModel to announce certain changes to model- makes UI reactive
    typealias Card = MemoryGame<String>.Card //so we don't have to type full type definition -> renamed to EmojiMemoryGame.Card
    static private let vehicleEmojis = ["🚗", "🛴", "✈️", "🛵", "⛵️", "🚎", "🚐", "🚛", "🛻", "🏎", "🚂", "🚊", "🚀", "🚁", "🚢", "🛶", "🛥", "🚞", "🚟", "🚃"]
    static private let animalEmojis = ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐻‍❄️", "🐨", "🐯", "🦁", "🐮", "🐷", "🐵"]
    static private let foodEmojis = ["🍔", "🥐", "🍕", "🥗", "🥟", "🍣", "🍪", "🍚", "🍝", "🥙", "🍭", "🍤", "🥞", "🍦", "🍛", "🍗"]
    static private let heartEmojis = ["❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍"]
    static private let sportsEmojis = ["⚽️", "🏀", "🏈", "⚾️", "🎾", "🏉", "🥏", "🏐", "🎱", "🏓", "🏸", "🏒", "🥊", "🚴‍♂️", "🏊", "🧗‍♀️", "🤺", "🏇", "🏋️‍♀️", "⛸", "⛷", "🏄", "🤼"]
    static private let weatherEmojis = ["☀️", "🌪", "☁️", "☔️", "❄️", "🌈", "🌊", "⛄️", "⛈️", "🌀"]
    
    static private func createMemoryGame(with theme: Theme) -> MemoryGame<String> { //static before so var model can be set
        MemoryGame<String>(numberOfPairsOfCards: 6) { pairIndex in theme.emojis[pairIndex] }
    }
        
    var cards: Array<Card> { //similar to get method, but recalcualted each time it's accessed
        model.cards //need to get fresh copy each time- structs copy self as passed around
    }
    
    private(set) var chosenTheme: Theme
    private(set) var chosenColor: Color
    
    @Published var model: MemoryGame<String> //@Published shows view anytime model has changed
    
    static private func chooseEmojis(from emojis: Array<String>) -> Array<String> {
        let shuffledEmojis = emojis.shuffled()
        var selectedEmojis = Array<String>()
        var numPairs = 10
        
        if shuffledEmojis.count < 10 {
            numPairs = shuffledEmojis.count
        }
        
        for num in 0..<numPairs {
            selectedEmojis.append(shuffledEmojis[num])
        }
        return selectedEmojis
    }
        
    static private func createTheme(named name: String, with chosenEmojis: Array<String>, numPairs: Int, color: String) -> Theme {
        let adjustedPairs: Int
        if numPairs > chosenEmojis.count {
            adjustedPairs = chosenEmojis.count
        } else {
            adjustedPairs = numPairs
        }
        return Theme(name: name, emojis: chosenEmojis, numPairs: adjustedPairs, color: color) //chooseEmojis(from: chosenEmojis)
    }
    
    static var allThemes: [Theme] {
        [
            createTheme(named: "Vehicles", with: chooseEmojis(from: vehicleEmojis), numPairs: 10, color: "red"),
            createTheme(named: "Animals", with: chooseEmojis(from: animalEmojis), numPairs: 10, color: "yellow"),
            createTheme(named: "Food", with: chooseEmojis(from: foodEmojis), numPairs: 10, color: "green"),
            createTheme(named: "Hearts", with: chooseEmojis(from: heartEmojis), numPairs: 10, color: "pink"),
            createTheme(named: "Sports", with: chooseEmojis(from: sportsEmojis), numPairs: 10, color: "blue"),
            createTheme(named: "Weather", with: chooseEmojis(from: weatherEmojis), numPairs: 10, color: "purple")
        ]
    }

    
    static private func chooseColor(of chosenTheme: Theme) -> Color {
        switch chosenTheme.color {
        case "red":
            return .red
        case "yellow":
            return .yellow
        case "green":
            return .green
        case "pink":
            return .pink
        case "blue":
            return .blue
        case "purple":
            return .purple
        default:
            return .black
        }
    }
    
    init() {
        chosenTheme = EmojiMemoryGame.allThemes.randomElement()!
        chosenColor = EmojiMemoryGame.chooseColor(of: chosenTheme)
        model = EmojiMemoryGame.createMemoryGame(with: chosenTheme)
    }
    
    
    
    
    // MARK: - Intent(s)
    
    func choose(_ card: MemoryGame<String>.Card) {
        model.choose(card)
    }
    
    func shuffle() {
        model.shuffle()
    }
    
    func restart() {
        chosenTheme = EmojiMemoryGame.allThemes.randomElement()!
        chosenColor = EmojiMemoryGame.chooseColor(of: chosenTheme)
        model = EmojiMemoryGame.createMemoryGame(with: chosenTheme)
    }
    
}
