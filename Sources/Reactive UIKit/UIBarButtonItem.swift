//
//  UIBarButtonItem.swift
//  ReactivePixel-iOS
//
//  Created by José Donor on 16/11/2018.
//

import ReactiveSwift
import ReactiveSwifty
import Result
import UIKit



extension UIBarButtonItem: ReactiveExtensionsProvider, LifetimeProvider {}

extension Reactive where Base: UIBarButtonItem {

	/// Bar button item was tapped.
	///
	/// Forwards events on main queue.
	public func wasTapped() -> SignalProducer<(), NoError> {

		return SignalProducer { [weak base] observer, disposable in

			guard let base = base else {
				observer.sendCompleted()
				return
			}

			let proxy = Proxy(barButtonItem: base) {
				observer.send(value: ())
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

	/// Targeted bar button item
	private weak var barButtonItem: UIBarButtonItem?
	/// Action to trigger on events
	private let action: () -> Void


	// MARK: - Initialize

	fileprivate init(barButtonItem: UIBarButtonItem,
					 action: @escaping () -> Void) {

		self.barButtonItem = barButtonItem
		self.action = action

		barButtonItem.target = self
		barButtonItem.action = #selector(listen)

	}

	deinit {
		stopListening()
	}


	@objc
	private func listen(_ sender: UIControl) {
		action()
	}

	fileprivate func stopListening() {
		barButtonItem?.target = nil
		barButtonItem?.action = nil
	}

}
