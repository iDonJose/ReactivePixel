/*:
 ## `selectedSegment`
 Sends selected segment index.
 */

import PlaygroundSupport
import ReactivePixel


let segmentControl = UISegmentedControl(items: ["One", "Two", "Three"])


/// Listens to selected segment index
segmentControl.reactive.selectedSegment
    .startWithValues { print("Selected segment : \($0)") }


PlaygroundPage.current.liveView = segmentControl


//: < [Summary](Summary) | [Next](@next) >
