//
//  CAAnimation.swift
//  ReactivePixel-iOS
//
//  Created by José Donor on 25/03/2019.
//

import ReactiveSwift
import Result



extension CAAnimation: ReactiveExtensionsProvider {}

extension Reactive where Base: CAAnimation {

	public func events() -> SignalProducer<CAAnimation.Event, NoError> {

		let proxy = Proxy(animation: base, action: nil)

		return SignalProducer { observer, disposable in

			proxy.action = {
				observer.send(value: $0)
				if $0 != .started { observer.sendCompleted() }
			}

			disposable.ended
				.observe(on: QueueScheduler.main)
				.observeCompleted { proxy.cleanUp() }

		}
		.start(on: QueueScheduler.main)
	}

}


extension CAAnimation {

	public enum Event: Equatable {
		case started
		case ended(finished: Bool)
	}

}


private final class Proxy: NSObject, CAAnimationDelegate {

	/// Targeted animation
	private weak var animation: CAAnimation?
	/// Action to trigger on events
	fileprivate var action: ((CAAnimation.Event) -> Void)?


	// MARK: - Initialize

	fileprivate init(animation: CAAnimation,
					 action: ((CAAnimation.Event) -> Void)?) {

		self.animation = animation
		self.action = action

		super.init()

		animation.delegate = self
	}

	deinit {
		cleanUp()
	}



	fileprivate func cleanUp() {
		animation?.delegate = nil
	}


	fileprivate func animationDidStart(_ animation: CAAnimation) {
		action?(.started)
	}

	fileprivate func animationDidStop(_ animation: CAAnimation,
									  finished: Bool) {
		action?(.ended(finished: finished))
	}

}
