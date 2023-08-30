import SwiftUI

struct EmojiMemoryGameView: View {
    @ObservedObject var game: EmojiMemoryGame //hooking up viewModel to view, allows to receive changes
    
    @Namespace private var dealingNamespace
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                gameBody
                HStack {
                    restart
                    Spacer()
                    shuffle
                }
                .padding(.horizontal)
            }
            deckBody
        }
        .padding()
    }
    
    @State private var dealt = Set<Int>()
    
    private func deal(_ card: EmojiMemoryGame.Card) {
        dealt.insert(card.id)
    }
    
    private func isUndealt(_ card: EmojiMemoryGame.Card) -> Bool {
        !dealt.contains(card.id)
    }
    
    private func dealAnimation(for card: EmojiMemoryGame.Card) -> Animation {
        var delay = 0.0
        if let index = game.cards.firstIndex(where: { $0.id == card.id }) {
            delay = Double(index) * (CardConstants.totalDealDuration / Double(game.cards.count))
        }
        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
    }
    
    private func zIndex(of card: EmojiMemoryGame.Card) -> Double { //high nums in front, low nums in back
        -Double(game.cards.firstIndex(where: { $0.id == card.id }) ?? 0)
    }
    
    var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: 2/3) { card in
            if isUndealt(card) || card.isMatched && !card.isFaceUp {
                Color.clear
            } else {
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .padding(4)
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
                    .zIndex(zIndex(of: card))
                    .onTapGesture {
                        withAnimation {
                            game.choose(card) //sends choose intent to viewModel
                        }
                    }
            }
        }
        .foregroundColor(CardConstants.color)
    }
    
    var deckBody: some View {
        ZStack {
            ForEach(game.cards.filter(isUndealt)) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .zIndex(zIndex(of: card))
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
                
            }
        }
        .frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
        .foregroundColor(CardConstants.color)
        .onTapGesture {
            //deal cards
            for card in game.cards {
                withAnimation(dealAnimation(for: card)) {
                    deal(card)
                }
            }
        }
    }
    
    var shuffle: some View {
        Button("Shuffle") {
            withAnimation {
                game.shuffle()
            }
        }
    }
    
    var restart: some View {
        Button("Restart") {
            withAnimation {
                dealt = []
                game.restart()
            }
        }
    }
    
    private struct CardConstants {
        static let color = Color.red
        static let aspectRatio: CGFloat = 2/3
        static let dealDuration: Double = 0.5
        static let totalDealDuration: Double = 2
        static let undealtHeight: CGFloat = 90
        static let undealtWidth = undealtHeight * aspectRatio
    }
}


struct CardView: View { //a view struct for each card
    let card: EmojiMemoryGame.Card
    
    @State private var animatedBonusRemaining: Double = 0
    
    var body: some View { //designing a card
        GeometryReader { geometry in
            ZStack {
                Group {
                    if card.isConsumingBonusTime {
                        Pie(startAngle: Angle(degrees: -90), endAngle: Angle(degrees: (1-animatedBonusRemaining) * 360 - 90))
                            .onAppear {
                                animatedBonusRemaining = card.bonusRemaining //start here
                                withAnimation(.linear(duration: card.bonusTimeRemaining)) {
                                    animatedBonusRemaining = 0 //animate to here
                                }
                            }
                    } else {
                        Pie(startAngle: Angle(degrees: -90), endAngle: Angle(degrees: (1-card.bonusRemaining) * 360 - 90))
                    }
                }
                    .padding(5)
                    .opacity(DrawingConstants.opacity)
                Text(card.content)
                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                    .animation(Animation.easeInOut(duration: 2), value: card.isMatched)
                    .font(Font.system(size: DrawingConstants.fontSize))
                    .scaleEffect(scale(thatFits: geometry.size))
            }
            .cardify(isFaceUp: card.isFaceUp)
        }
    }
    
    private func scale(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) / (DrawingConstants.fontSize / DrawingConstants.fontScale)
    }
    
    
    private struct DrawingConstants { //can only have static let constants
        static let fontScale: CGFloat = 0.65 //controls how big the emojis are
        static let fontSize: CGFloat = 32
        static let opacity: CGFloat = 0.5
        
    }
}
