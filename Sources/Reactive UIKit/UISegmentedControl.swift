//
//  UISegmentedControl.swift
//  ReactivePixel-iOS
//
//  Created by José Donor on 17/11/2018.
//

import ReactiveSwift
import Result
import UIKit



extension Reactive where Base: UISegmentedControl {

	/// Index of selected segment.
	///
	/// Forwards events on main queue.
	public var selectedSegment: SignalProducer<Int, NoError> {

		return events(.valueChanged)
			.filterMap { [weak base] _ in base?.selectedSegmentIndex }
	}

}
