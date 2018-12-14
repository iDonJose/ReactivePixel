//
//  UITextField.swift
//  ReactivePixel-iOS
//
//  Created by José Donor on 17/11/2018.
//

import ReactiveSwift
import Result
import UIKit



extension Reactive where Base: UITextField {

	/// User iteraction events sent by TextField.
	///
	/// Forwards events on main queue.
	/// - Warning: UITextField's delegate will be set.
	///
	/// - Parameter events: Events to listen to
	/// - Returns: A SignalProducer of events.
	public func editEvents(_ events: UITextField.EditEvent,
                           shouldClear: (() -> Bool)? = nil,
                           shouldReturn: (() -> Bool)? = nil,
                           shouldStartEditing: (() -> Bool)? = nil,
                           shouldEndEditing: (() -> Bool)? = nil,
                           shouldChangeCharacters: ((_ range: NSRange, _ replacement: String) -> Bool)? = nil) -> SignalProducer<UITextField.EditEvent, NoError> {

		return SignalProducer { [weak base] observer, disposable in

			guard let base = base else {
				observer.sendCompleted()
				return
			}

            let action: (UITextField.EditEvent) -> Void = { event in
                observer.send(value: event)
            }

            let proxy = Proxy(textField: base,
                              events: events,
                              action: action,
                              shouldClear: shouldClear,
                              shouldReturn: shouldReturn,
                              shouldStartEditing: shouldStartEditing,
                              shouldEndEditing: shouldEndEditing,
                              shouldChangeCharacters: shouldChangeCharacters)

			disposable.ended
				.observe(on: UIScheduler())
				.observeCompleted { proxy.stopListening() }

		}
		.start(on: UIScheduler())
		.take(during: base.lifetime)

	}

	/// TextField's current text.
	///
	/// Forwards events on main queue.
	/// - Warning: UITextField's delegate will be set.
	public var text: SignalProducer<String, NoError> {

		return editEvents(.editingChange)
			.filterMap { [weak base] _ in base?.text }
	}

	/// TextField's current attributed text.
	///
	/// Forwards events on main queue.
	/// - Warning: UITextField's delegate will be set.
	public var attributedText: SignalProducer<NSAttributedString, NoError> {

		return editEvents(.editingChange)
			.filterMap { [weak base] _ in base?.attributedText }
	}

}


extension UITextField {

	/// Event that is produced by listening to UITextFieldDelegate and editing changes on a UITextField
	public struct EditEvent: OptionSet {

		public let rawValue: UInt


		public static let editingStart = EditEvent(rawValue: 1 << 0)
		public static let editingEnd = EditEvent(rawValue: 1 << 1)
		public static let editingChange = EditEvent(rawValue: 1 << 2)
		public static let clear = EditEvent(rawValue: 1 << 3)
		public static let `return` = EditEvent(rawValue: 1 << 4)

		public static let all: EditEvent = [.editingStart, .editingEnd, .editingChange, .clear, .return]

		// MARK: - Initialize

		public init(rawValue: UInt) { self.rawValue = rawValue }

	}

}


private final class Proxy: NSObject, UITextFieldDelegate {

	/// Targeted textField
	private weak var textField: UITextField?
	/// Events to listen to
	private let events: UITextField.EditEvent
	/// Action to trigger on events
	private let action: (UITextField.EditEvent) -> Void


    // MARK: Delegate Callbacks

    private let shouldClear: (() -> Bool)?
    private let shouldReturn: (() -> Bool)?
    private let shouldStartEditing: (() -> Bool)?
    private let shouldEndEditing: (() -> Bool)?
    private let shouldChangeCharacters: ((_ range: NSRange, _ replacement: String) -> Bool)?


	// MARK: - Initialize

	fileprivate init(textField: UITextField,
					 events: UITextField.EditEvent,
					 action: @escaping (UITextField.EditEvent) -> Void,
                     shouldClear: (() -> Bool)?,
                     shouldReturn: (() -> Bool)?,
                     shouldStartEditing: (() -> Bool)?,
                     shouldEndEditing: (() -> Bool)?,
                     shouldChangeCharacters: ((_ range: NSRange, _ replacement: String) -> Bool)?) {

		self.textField = textField
		self.events = events
		self.action = action

        self.shouldClear = shouldClear
        self.shouldReturn = shouldReturn
        self.shouldStartEditing = shouldStartEditing
        self.shouldEndEditing = shouldEndEditing
        self.shouldChangeCharacters = shouldChangeCharacters

		super.init()

		textField.addTarget(self, action: #selector(didChangeText), for: .editingChanged)

		/// Use a delegate only when some events either than editing changed are needed
		if events != .editingChange {
			textField.delegate = self
		}

		/// Simulates an edit change for initial value
		if events.contains(.editingChange) {
			action(.editingChange)
		}

	}

	deinit {
		stopListening()
	}


	@objc
	private func didChangeText() {
        action(.editingChange)
	}

	fileprivate func stopListening() {
		textField?.removeTarget(self, action: #selector(didChangeText), for: .editingChanged)
		textField?.delegate = nil
	}


	// MARK: - UITextFieldDelegate

	func textFieldDidBeginEditing(_ textField: UITextField) {
        if events.contains(.editingStart) {
            action(.editingStart)
        }
	}

	@available(iOS 10.0, *)
	func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if events.contains(.editingEnd) {
            action(.editingEnd)
        }
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
        if events.contains(.editingEnd) {
            action(.editingEnd)
        }
	}

	func textFieldShouldClear(_ textField: UITextField) -> Bool {
        let clears = shouldClear?() ?? true
        if clears && events.contains(.clear) {
            action(.clear)
        }
		return clears
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let returns = shouldReturn?() ?? true
        if returns && events.contains(.return) {
            action(.return)
        }
		return returns
	}



    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return shouldStartEditing?() ?? true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return shouldEndEditing?() ?? true
    }


    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return shouldChangeCharacters?(range, string) ?? true
    }

}
