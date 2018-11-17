//
//  UIControl.swift
//  ReactivePixel-iOS
//
//  Created by José Donor on 17/11/2018.
//

import ReactiveSwift
import Result
import UIKit



extension Reactive where Base: UIControl {

	/// User iteraction events sent by control.
	///
	/// Forwards events on main queue.
	///
	/// - Parameter events: Events to listen to
	/// - Returns: A SignalProducer of events.
	public func events(_ events: UIControl.Event) -> SignalProducer<UIEvent, NoError> {

		return SignalProducer { [weak base] observer, disposable in

			guard let base = base else {
				observer.sendCompleted()
				return
			}

			let proxy = Proxy(control: base, events: events) { event in
				observer.send(value: event)
			}

			disposable.ended
				.observe(on: UIScheduler())
				.observeCompleted { proxy.stopListening() }

		}
		.start(on: UIScheduler())
		.take(during: base.lifetime)

	}

}


private final class Proxy {

	/// Targeted control
	private weak var control: UIControl?
	/// Events to listen to
	private let events: UIControl.Event
	/// Action to trigger on events
	private let action: (UIEvent) -> Void


	// MARK: - Initialize

	fileprivate init(control: UIControl,
					 events: UIControl.Event,
					 action: @escaping (UIEvent) -> Void) {

		self.control = control
		self.events = events
		self.action = action

		/// Simulates a value change for initial value
		if case events = UIControl.Event.valueChanged {
			action(UIEvent())
		}

		control.addTarget(self, action: #selector(listen(_:event:)), for: events)

	}

	deinit {
		stopListening()
	}



	@objc
	private func listen(_ sender: UIControl,
					  	event: UIEvent) {
		action(event)
	}

	fileprivate func stopListening() {
		control?.removeTarget(self, action: #selector(self.listen), for: self.events)
	}

}
