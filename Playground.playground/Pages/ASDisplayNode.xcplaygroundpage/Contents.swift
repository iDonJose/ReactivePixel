/*:
 ## `gesture`
 Sends gesture events.
 */

import AsyncDisplayKit
import PlaygroundSupport
import ReactivePixel


let node = ASDisplayNode()
node.frame.size = .init(width: 80, height: 80)
node.backgroundColor = #colorLiteral(red: 0.9305117997, green: 1, blue: 0.3434988222, alpha: 1)


/// Listens to gesture events
node.reactive.gesture(UITapGestureRecognizer())
    .startWithValues { gesture in print("👉 Tap : \(gesture.state)") }


PlaygroundPage.current.liveView = node.view


//: < [Summary](Summary) | [Next](@next) >
