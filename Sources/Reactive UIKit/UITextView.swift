//
//  UITextView.swift
//  ReactivePixel-iOS
//
//  Created by José Donor on 17/11/2018.
//

import ReactiveSwift
import Result
import UIKit



extension Reactive where Base: UITextView {

	/// User iteraction events sent by TextView.
	///
	/// Forwards events on main queue.
	/// - Warning: UITextView's delegate will be set.
	///
	/// - Parameter events: Events to listen to
	/// - Returns: A SignalProducer of events.
	public func editEvents(_ events: UITextView.EditEvent) -> SignalProducer<UITextView.EditEvent, NoError> {

		return SignalProducer { [weak base] observer, disposable in

			guard let base = base else {
				observer.sendCompleted()
				return
			}

			let proxy = Proxy(textView: base, events: events) { event in
				observer.send(value: event)
			}

			disposable.ended
				.observe(on: UIScheduler())
				.observeCompleted { proxy.stopListening() }

		}
		.start(on: UIScheduler())
		.take(during: base.lifetime)

	}

	/// TextView's current text.
	///
	/// Forwards events on main queue.
	/// - Warning: UITextView's delegate will be set.
	public var text: SignalProducer<String, NoError> {

		return editEvents(.editingChange)
			.filterMap { [weak base] _ in base?.text }
	}

	/// TextView's current attributed text.
	///
	/// Forwards events on main queue.
	/// - Warning: UITextView's delegate will be set.
	public var attributedText: SignalProducer<NSAttributedString, NoError> {

		return editEvents(.editingChange)
			.filterMap { [weak base] _ in base?.attributedText }
	}

}


extension UITextView {

	/// Event that is produced by listening to UITextViewDelegate and editing changes on a UITextView
	public struct EditEvent: OptionSet {

		public let rawValue: UInt

		public static let editingStart = EditEvent(rawValue: 1 << 0)
		public static let editingEnd = EditEvent(rawValue: 1 << 1)
		public static let editingChange = EditEvent(rawValue: 1 << 2)
		public static let selectionChange = EditEvent(rawValue: 1 << 3)

		public static let all: EditEvent = [.editingStart, .editingEnd, .editingChange, .selectionChange]

		// MARK: - Initialize

		public init(rawValue: UInt) { self.rawValue = rawValue }

	}

}


private final class Proxy: NSObject, UITextViewDelegate {

	/// Targeted TextView
	private weak var textView: UITextView?
	/// Events to listen to
	private let events: UITextView.EditEvent
	/// Action to trigger on events
	private let action: (UITextView.EditEvent) -> Void


	// MARK: - Initialize

	fileprivate init(textView: UITextView,
					 events: UITextView.EditEvent,
					 action: @escaping (UITextView.EditEvent) -> Void) {

		self.textView = textView
		self.events = events
		self.action = action
		super.init()

		textView.delegate = self

		/// Simulates an edit change for initial value
		if events.contains(.editingChange) {
			action(.editingChange)
		}

	}

	deinit {
		stopListening()
	}


	fileprivate func stopListening() {
		textView?.delegate = nil
	}


	// MARK: - UITextViewDelegate

	func textViewDidBeginEditing(_ textView: UITextView) {
		action(.editingStart)
	}

	func textViewDidEndEditing(_ textView: UITextView) {
		action(.editingEnd)
	}

	func textViewDidChange(_ textView: UITextView) {
		action(.editingChange)
	}

	func textViewDidChangeSelection(_ textView: UITextView) {
		action(.selectionChange)
	}

}
