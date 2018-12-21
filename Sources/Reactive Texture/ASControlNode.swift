//
//  ASControlNode.swift
//  ReactivePixel-iOS
//
//  Created by José Donor on 17/11/2018.
//

import AsyncDisplayKit
import ReactiveSwift
import Result



extension Reactive where Base: ASControlNode {

	/// User iteraction events sent by control.
	///
	/// Forwards events on main queue.
	///
	/// - Parameter events: Events to listen to
	/// - Returns: A SignalProducer of events.
	public func events(_ events: ASControlNodeEvent) -> SignalProducer<UIEvent, NoError> {

		return SignalProducer { [weak base] observer, disposable in

			guard let base = base else {
				observer.sendCompleted()
				return
			}

			let proxy = Proxy(control: base, events: events) { event in
				observer.send(value: event)
			}

			disposable.ended
				.observe(on: QueueScheduler.main)
				.observeCompleted { proxy.stopListening() }

		}
		.start(on: QueueScheduler.main)
        .take(during: base.lifetime)

	}

}


private final class Proxy {

	/// Targeted control
	private weak var control: ASControlNode?
	/// Events to listen to
	private let events: ASControlNodeEvent
	/// Action to trigger on events
	private let action: (UIEvent) -> Void


	// MARK: - Initialize

	fileprivate init(control: ASControlNode,
					 events: ASControlNodeEvent,
					 action: @escaping (UIEvent) -> Void) {

		self.control = control
		self.events = events
		self.action = action

		/// Simulate a value change for initial value
		if case events = ASControlNodeEvent.valueChanged {
			action(UIEvent())
		}

		control.addTarget(self, action: #selector(listen(_:event:)), forControlEvents: events)

	}

	deinit {
		stopListening()
	}



	@objc
	private func listen(_ sender: ASControlNode,
						event: UIEvent) {
		action(event)
	}

	fileprivate func stopListening() {
		control?.removeTarget(self, action: #selector(self.listen), forControlEvents: self.events)
	}

}
