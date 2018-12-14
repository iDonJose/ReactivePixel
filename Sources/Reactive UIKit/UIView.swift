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
	public func gesture<T: UIGestureRecognizer>(_ gestureRecognizer: T,
												shouldStart: (() -> Bool)? = nil,
												shouldRecognizeSimultaneouslyWith: ((_ gestureRecognizer: UIGestureRecognizer) -> Bool)? = nil,
												shouldRequireFailureOf: ((_ gestureRecognizer: UIGestureRecognizer) -> Bool)? = nil,
												shouldBeRequiredToFailBy: ((_ gestureRecognizer: UIGestureRecognizer) -> Bool)? = nil,
												shouldReceiveTouch: ((UITouch) -> Bool)? = nil,
												shouldReceivePress: ((UIPress) -> Bool)? = nil) -> SignalProducer<T, NoError> {

		return SignalProducer { [weak base] observer, disposable in

			guard let base = base else {
				observer.sendCompleted()
				return
			}

			let action: (T) -> Void = { gestureRecognizer in
				observer.send(value: gestureRecognizer)
			}

			let proxy = Proxy(view: base,
							  gestureRecognizer: gestureRecognizer,
							  action: action,
							  shouldStart: shouldStart,
							  shouldRecognizeSimultaneouslyWith: shouldRecognizeSimultaneouslyWith,
							  shouldRequireFailureOf: shouldRequireFailureOf,
							  shouldBeRequiredToFailBy: shouldBeRequiredToFailBy,
							  shouldReceiveTouch: shouldReceiveTouch,
							  shouldReceivePress: shouldReceivePress)

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


	// MARK: Delegate Callbacks

	private let shouldStart: (() -> Bool)?
	private let shouldRecognizeSimultaneouslyWith: ((_ gestureRecognizer: UIGestureRecognizer) -> Bool)?
	private let shouldRequireFailureOf: ((_ gestureRecognizer: UIGestureRecognizer) -> Bool)?
	private let shouldBeRequiredToFailBy: ((_ gestureRecognizer: UIGestureRecognizer) -> Bool)?
	private let shouldReceiveTouch: ((UITouch) -> Bool)?
	private let shouldReceivePress: ((UIPress) -> Bool)?


	// MARK: - Initialize

	fileprivate init(view: UIView,
					 gestureRecognizer: GestureRecognizer,
					 action: @escaping (GestureRecognizer) -> Void,
					 shouldStart: (() -> Bool)?,
					 shouldRecognizeSimultaneouslyWith: ((_ gestureRecognizer: UIGestureRecognizer) -> Bool)?,
					 shouldRequireFailureOf: ((_ gestureRecognizer: UIGestureRecognizer) -> Bool)?,
					 shouldBeRequiredToFailBy: ((_ gestureRecognizer: UIGestureRecognizer) -> Bool)?,
					 shouldReceiveTouch: ((UITouch) -> Bool)?,
					 shouldReceivePress: ((UIPress) -> Bool)?) {

		self.view = view
		self.gestureRecognizer = gestureRecognizer
		self.action = action

		self.shouldStart = shouldStart
		self.shouldRecognizeSimultaneouslyWith = shouldRecognizeSimultaneouslyWith
		self.shouldRequireFailureOf = shouldRequireFailureOf
		self.shouldBeRequiredToFailBy = shouldBeRequiredToFailBy
		self.shouldReceiveTouch = shouldReceiveTouch
		self.shouldReceivePress = shouldReceivePress

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


	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		return shouldStart?() ?? true
	}

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
						   shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return shouldRecognizeSimultaneouslyWith?(otherGestureRecognizer) ?? false
	}

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
						   shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return shouldRequireFailureOf?(otherGestureRecognizer) ?? false
	}

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
						   shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return shouldBeRequiredToFailBy?(otherGestureRecognizer) ?? false
	}

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
						   shouldReceive touch: UITouch) -> Bool {
		return shouldReceiveTouch?(touch) ?? true
	}

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
						   shouldReceive press: UIPress) -> Bool {
		return shouldReceivePress?(press) ?? true
	}

}
