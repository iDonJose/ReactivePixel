//
//  ASDisplayNode.swift
//  ReactivePixel-iOS
//
//  Created by José Donor on 17/11/2018.
//

import AsyncDisplayKit
import ReactiveSwift
import ReactiveSwifty
import Result



extension ASDisplayNode: ReactiveExtensionsProvider, LifetimeProvider {}

extension Reactive where Base: ASDisplayNode {

	/// Listens to events emited by a GestureRecognizer.
	///
	/// Forwards events on main queue.
	///
	/// - Parameter gestureRecognizer: A UIGestureRecognizer.
	/// - Returns: A SignalProducer of UIGestureRecognizer.
	public func gesture<T: UIGestureRecognizer>(_ gestureRecognizer: T) -> SignalProducer<T, NoError> {

		return base.view.reactive.gesture(gestureRecognizer)
	}

}
