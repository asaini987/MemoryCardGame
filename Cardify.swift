import SwiftUI

struct Cardify: AnimatableModifier {

    init(isFaceUp: Bool) {
        rotation = isFaceUp ? 0 : 180
    }
    
    var animatableData: Double { //link this var to actual var used in code (rotation), made rotation animatable
        get {
            rotation
        }
        set {
            rotation = newValue
        }
    }

    var rotation: Double //in degrees, drives UI
    
    func body(content: Content) -> some View { //content is what we're modifying
        ZStack {
            let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
            if rotation < 90 { //if face up
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
            }  else { //make cards look face down
                shape.fill()
            }
            content //put after for animations
                .opacity(rotation < 90 ? 1 : 0)
        }
        .rotation3DEffect(Angle.degrees(rotation), axis: (0,1,0)) //rotating about unit y vector
    }
    
    private struct DrawingConstants { //can only have static let constants
        static let cornerRadius: CGFloat = 10
        static let lineWidth: CGFloat = 3
    }
}

extension View {
    func cardify(isFaceUp: Bool) -> some View {
        self.modifier(Cardify(isFaceUp: isFaceUp))
    }
}
