//
//  UIRefreshControl.swift
//  ReactivePixel-iOS
//
//  Created by José Donor on 17/11/2018.
//

import ReactiveSwift
import Result
import UIKit



extension Reactive where Base: UIRefreshControl {

	/// Refresh operation status.
	///
	/// Forwards events on main queue.
	public var isRefreshing: SignalProducer<Bool, NoError> {

		return events(.valueChanged)
			.filterMap { [weak base] _ in base?.isRefreshing }
	}

}
