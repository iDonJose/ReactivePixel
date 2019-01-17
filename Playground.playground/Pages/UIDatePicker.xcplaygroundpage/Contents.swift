/*:
 ## `date`
 Sends new date values.
 */

import PlaygroundSupport
import ReactivePixel


let datePicker = UIDatePicker(frame: .init(origin: .zero,
                                           size: CGSize(width: 320, height: 120)))
datePicker.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)


/// Listens to date
datePicker.reactive.date
    .startWithValues { print("📅 > \($0)") }


PlaygroundPage.current.liveView = datePicker

//: < [Summary](Summary) | [Next](@next) >
