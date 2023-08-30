import Foundation

struct MemoryGame<CardContent> where CardContent: Equatable { //Equatable allows CardContent to be comapred with == operator
    private(set) var cards: Array<Card>
    
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get { cards.indices.filter({ cards[$0].isFaceUp }).oneAndOnly } //filters list of cards that are face up: returns element if count is 1, returns nil if not
        set { cards.indices.forEach { cards[$0].isFaceUp = ($0 == newValue) } } //go through indices, make card face up if the user chose it, face down the rest
    }

    mutating func choose(_ card: Card) { //mutating allows func to change immutable self
        
        if let chosenIndex = cards.firstIndex(where: { $0.id == card.id }),
            !cards[chosenIndex].isFaceUp,
            !cards[chosenIndex].isMatched
        {   //unwrapping optional and searching for chosen card in array (don't do anything to face up AND matched cards)
            
            if let potentialMatchIndex = indexOfOneAndOnlyFaceUpCard { //if 1 card is already face up
                
                if cards[chosenIndex].content == cards[potentialMatchIndex].content { //if chosen card and already flipped card's content is the same (match)
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                }
                cards[chosenIndex].isFaceUp = true //after turning all cards face down or comparing it with another card, flip chosen card face up
                
            } else { //if all cards face down or 2 cards already face up -> turn all cards face down
                indexOfOneAndOnlyFaceUpCard = chosenIndex //since all cards face down, set chosen card index to be the only face up card index
            }
        }
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
    

    init(numberOfPairsOfCards: Int, createCardContent: (Int) -> CardContent) { //taking func created by viewModel to make generic
        cards = [] //setting cards property to empty list, not new var
        //adds number of pairs of cards to cards array
        for pairIndex in 0..<numberOfPairsOfCards {
            let content = createCardContent(pairIndex)
            cards.append(Card(content: content, id: pairIndex * 2))
            cards.append(Card(content: content, id: (pairIndex * 2) + 1))
        }
        cards.shuffle()
    }
    
    
    
    struct Card: Identifiable { // nested to specify this is card in a memory game - memorygame.card
        var isFaceUp = false
        var isMatched = false
        let content: CardContent    // generic allows to have any data type on card
        let id: Int
        var alreadySeen = false
    }
}
    
struct Theme {
    let name: String
    let emojis: Array<String>
    let numPairs: Int
    let cardColor: String
}

extension Array {
    var oneAndOnly: Element? { // option b/c one and only
        if self.count == 1 {            // self represents the array itself (can be omitted)
            return self.first
        } else {
            return nil
        }
    }
    
}
