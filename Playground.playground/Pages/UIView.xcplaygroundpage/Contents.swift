/*:
 ## `gesture`
 Sends gesture events.
 */

import PlaygroundSupport
import ReactivePixel


let view = UIView(frame: .init(origin: .zero,
                               size: .init(width: 80, height: 80)))
view.backgroundColor = #colorLiteral(red: 0.9305117997, green: 1, blue: 0.3434988222, alpha: 1)


/// Listens to gesture events
view.reactive.gesture(UITapGestureRecognizer())
    .startWithValues { _ in print("👉📱") }


PlaygroundPage.current.liveView = view


//: < [Summary](Summary) | [Next](@next) >
