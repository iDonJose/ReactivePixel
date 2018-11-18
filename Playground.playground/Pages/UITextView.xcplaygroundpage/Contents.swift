import PlaygroundSupport
import ReactivePixel


let textView = UITextView(frame: .init(origin: .zero,
                                         size: .init(width: 120, height: 60)))
textView.backgroundColor = #colorLiteral(red: 0.5837298334, green: 0.6842804686, blue: 1, alpha: 1)


/*:
 ### `editEvents`
 Sends user interaction events.
 */

textView.reactive.text
    .startWithValues { print("Text : \($0)") }

/*:
 ### `attributedText`
 Sends attributed text on change.
 */

textView.reactive.attributedText
    .startWithValues { print("Attributed text : \($0)") }

/*:
 ### `editEvents`
 Sends user interaction events.
 */

textView.reactive.editEvents(.all)
    .startWithValues { print("Event : \($0)") }


PlaygroundPage.current.liveView = textView

//: < [Summary](Summary) | [Next](@next) >
