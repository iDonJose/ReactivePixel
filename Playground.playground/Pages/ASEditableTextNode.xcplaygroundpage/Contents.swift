import AsyncDisplayKit
import PlaygroundSupport
import ReactivePixel


let editableText = ASEditableTextNode()
editableText.frame.size = .init(width: 120, height: 60)
editableText.backgroundColor = #colorLiteral(red: 0.165422491, green: 0.9609375, blue: 0.6502349596, alpha: 1)

/*:
 ### `text`
 Sends text on change.
 */

editableText.reactive.text
    .startWithValues { print("Text : \($0)") }

/*:
 ### `attributedText`
 Sends attributed text on change.
 */

editableText.reactive.attributedText
    .startWithValues { print("Attributed text : \($0)") }

/*:
 ### `editEvents`
 Sends user interaction events.
 */

editableText.reactive.editEvents(.all)
    .startWithValues { print("Event : \($0)") }


PlaygroundPage.current.liveView = editableText.view

//: < [Summary](Summary) | [Next](@next) >
