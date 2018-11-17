/*:
 ## `value`
 Sends slider's value.
 */

import PlaygroundSupport
import ReactivePixel


let slider = UISlider(frame: .init(origin: .zero,
                                   size: .init(width: 120, height: 40)))
slider.backgroundColor = #colorLiteral(red: 0.8182633014, green: 0.8832206009, blue: 0.9573625837, alpha: 1)


/// Listens to slider's value
slider.reactive.value
    .startWithValues { print("Value : \($0)") }


PlaygroundPage.current.liveView = slider


//: < [Summary](Summary) | [Next](@next) >
