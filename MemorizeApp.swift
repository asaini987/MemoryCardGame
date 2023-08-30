import SwiftUI

@main
struct AAMemorizeApp: App {
    private let game = EmojiMemoryGame() //game is a pointer to viewModel- can't change itself but reference can change
    
    var body: some Scene {
        WindowGroup {
            EmojiMemoryGameView(game: game)
        }
    }
}
