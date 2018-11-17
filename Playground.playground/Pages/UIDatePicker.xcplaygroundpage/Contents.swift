/*:
 ## `date`
 Sends new date values.
 */

import PlaygroundSupport
import ReactivePixel


let datePicker = UIDatePicker(frame: .init(origin: .zero,
                                           size: CGSize(width: 320, height: 120)))
datePicker.backgroundColor = #colorLiteral(red: 0.6023414264, green: 1, blue: 0.7418347267, alpha: 1)


/// Listens to date
datePicker.reactive.date
    .startWithValues { print("📅 > \($0)") }


PlaygroundPage.current.liveView = datePicker

//: < [Summary](Summary) | [Next](@next) >
