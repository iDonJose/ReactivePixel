//
//  UIView.swift
//  ReactivePixel-iOS
//
//  Created by José Donor on 17/11/2018.
//

// swiftlint:disable force_cast

import ReactiveSwift
import ReactiveSwifty
import Result
import UIKit



extension UIView: ReactiveExtensionsProvider, LifetimeProvider {}

extension Reactive where Base: UIView {

	/// Listens to events emited by a GestureRecognizer.
	///
	/// Forwards events on main queue.
	/// - Warning: UIGestureRecognizer's delegate will be set.
	///
	/// - Parameter gestureRecognizer: A UIGestureRecognizer.
	/// - Returns: A SignalProducer of UIGestureRecognizer.
	public func gesture<T: UIGestureRecognizer>(_ gestureRecognizer: T) -> SignalProducer<T, NoError> {

		return SignalProducer { [weak base] observer, disposable in

			guard let base = base else {
				observer.sendCompleted()
				return
			}

			let proxy = Proxy(view: base, gestureRecognizer: gestureRecognizer) { event in
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


private final class Proxy<GestureRecognizer: UIGestureRecognizer>: NSObject, UIGestureRecognizerDelegate {

	/// Targeted View
	private weak var view: UIView?
	/// Gesture recognizer
	private let gestureRecognizer: GestureRecognizer
	/// Action to trigger on gestures
	private let action: (GestureRecognizer) -> Void


	// MARK: - Initialize

	fileprivate init(view: UIView,
					 gestureRecognizer: GestureRecognizer,
					 action: @escaping (GestureRecognizer) -> Void) {

		self.view = view
		self.gestureRecognizer = gestureRecognizer
		self.action = action
		super.init()

		gestureRecognizer.addTarget(self, action: #selector(listen))
		view.addGestureRecognizer(gestureRecognizer)

	}

	deinit {
		stopListening()
	}


	@objc
	private func listen(_ gestureRecognizer: UIGestureRecognizer) {
		action(gestureRecognizer as! GestureRecognizer)
	}

	fileprivate func stopListening() {
		view?.removeGestureRecognizer(self.gestureRecognizer)
	}

}
