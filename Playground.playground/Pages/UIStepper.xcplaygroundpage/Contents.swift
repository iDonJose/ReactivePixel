/*:
 ## `value`
 Sends stepper's value.
 */

import PlaygroundSupport
import ReactivePixel


let stepper = UIStepper(frame: .init(origin: .zero,
                                     size: .init(width: 120, height: 40)))


/// Listens to stepper's value
stepper.reactive.value
    .startWithValues { print("Value : \($0)") }


PlaygroundPage.current.liveView = stepper


//: < [Summary](Summary) | [Next](@next) >
