/*:
 ### `text`
 Sends text on change.

 ### `attributedText`
 Sends attributed text on change.

 ### `editEvents`
 Sends user interaction events.
 */

import PlaygroundSupport
import ReactivePixel


let textField = UITextField(frame: .init(origin: .zero,
                                         size: .init(width: 120, height: 60)))
textField.backgroundColor = #colorLiteral(red: 0.5837298334, green: 0.6842804686, blue: 1, alpha: 1)


/// Listens to text changes
textField.reactive.text
    .startWithValues { print("Text : \($0)") }

/// Listens to attributed text changes
textField.reactive.attributedText
    .startWithValues { print("Attributed text : \($0)") }

/// Listens to events
textField.reactive.editEvents(.all)
    .startWithValues { print("Event : \($0)") }


PlaygroundPage.current.liveView = textField

//: < [Summary](Summary) | [Next](@next) >
