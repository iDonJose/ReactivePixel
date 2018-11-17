/*:
 ## `isOn`
 Sends switch's on/off state.
 */

import PlaygroundSupport
import ReactivePixel


let `switch` = UISwitch()
`switch`.backgroundColor = #colorLiteral(red: 0.8182633014, green: 0.8832206009, blue: 0.9573625837, alpha: 1)


/// Listens to switch on/off state
`switch`.reactive.isOn
    .startWithValues { print($0 ? "is on" : "is off") }


PlaygroundPage.current.liveView = `switch`


//: < [Summary](Summary) | [Next](@next) >
