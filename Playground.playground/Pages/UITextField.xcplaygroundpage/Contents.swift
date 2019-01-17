import PlaygroundSupport
import ReactivePixel


let textField = UITextField(frame: .init(origin: .zero,
                                         size: .init(width: 800, height: 1200)))
textField.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)


/*:
 ### `text`
 Sends text on change.
 */

textField.reactive.text
    .startWithValues { print("Text : \($0)") }

/*:
 ### `attributedText`
 Sends attributed text on change.
 */

textField.reactive.attributedText
    .startWithValues { print("Attributed text : \($0)") }

/*:
 ### `editEvents`
 Sends user interaction events.
 */

textField.reactive.editEvents(.all)
    .startWithValues { print("Event : \($0)") }


PlaygroundPage.current.liveView = textField

//: < [Summary](Summary) | [Next](@next) >
