/*:
 ## `wasTapped()`
 Pings when UIBarButtonItem is tapped.
 */

import PlaygroundSupport
import ReactivePixel


let toolBar = UIToolbar(frame: .init(origin: .zero,
                                     size: CGSize(width: 60, height: 60)))
toolBar.backgroundColor = #colorLiteral(red: 0.6313844168, green: 0.8577711796, blue: 1, alpha: 1)

let button = UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

toolBar.items = [space, button, space]


/// Listens to taps
button.reactive.wasTapped
    .startWithValues { _ in print("👉 Tap") }


PlaygroundPage.current.liveView = toolBar

//: < [Summary](Summary) | [Next](@next) >
