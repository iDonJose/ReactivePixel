//
//  UIDatePicker.swift
//  ReactivePixel-iOS
//
//  Created by José Donor on 17/11/2018.
//

import ReactiveSwift
import Result
import UIKit



extension Reactive where Base: UIDatePicker {

	/// Date picker's current date.
	///
	/// Forwards events on main queue.
	public var date: SignalProducer<Date, NoError> {

		return events(.valueChanged)
			.filterMap { [weak base] _ in base?.date }
	}

}
