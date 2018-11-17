//
//  UISwitch.swift
//  ReactivePixel-iOS
//
//  Created by José Donor on 17/11/2018.
//

import ReactiveSwift
import Result
import UIKit



extension Reactive where Base: UISwitch {

	/// Switch's on/off state.
	///
	/// Forwards events on main queue.
	public var isOn: SignalProducer<Bool, NoError> {

		return events(.valueChanged)
			.filterMap { [weak base] _ in base?.isOn }
	}

}
