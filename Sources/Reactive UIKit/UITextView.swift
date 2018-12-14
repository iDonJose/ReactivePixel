//
//  UITextView.swift
//  ReactivePixel-iOS
//
//  Created by José Donor on 17/11/2018.
//

// swiftlint:disable force_cast

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
	@available(iOS 10.0, *)
	public func editEvents(_ events: UITextView.EditEvent,
						   shouldStartEditing: (() -> Bool)? = nil,
						   shouldEndEditing: (() -> Bool)? = nil,
						   shouldChangeText: ((_ range: NSRange, _ replacement: String) -> Bool)? = nil,
						   shouldInteractWithURL: ((_ URL: URL, _ range: NSRange, _ interaction: UITextItemInteraction) -> Bool)? = nil,
						   shouldInteractWithTextAttachment: ((_ textAttachment: NSTextAttachment, _ range: NSRange, _ interaction: UITextItemInteraction) -> Bool)? = nil) -> SignalProducer<UITextView.EditEvent, NoError> {

		return SignalProducer { [weak base] observer, disposable in

			guard let base = base else {
				observer.sendCompleted()
				return
			}

			let action: (UITextView.EditEvent) -> Void = { event in
				observer.send(value: event)
			}

			var _shouldInteractWithURL: ((_ URL: URL, _ range: NSRange, _ interaction: Any?) -> Bool)?
			if let shouldInteractWithURL = shouldInteractWithURL {
				_shouldInteractWithURL = { shouldInteractWithURL($0, $1, $2 as! UITextItemInteraction) }
			}

			var _shouldInteractWithTextAttachment: ((_ textAttachment: NSTextAttachment, _ range: NSRange, _ interaction: Any?) -> Bool)?
			if let shouldInteractWithTextAttachment = shouldInteractWithTextAttachment {
				_shouldInteractWithTextAttachment = { shouldInteractWithTextAttachment($0, $1, $2 as! UITextItemInteraction) }
			}

			let proxy = Proxy(textView: base,
							  events: events,
							  action: action,
							  shouldStartEditing: shouldStartEditing,
							  shouldEndEditing: shouldEndEditing,
							  shouldChangeText: shouldChangeText,
							  shouldInteractWithURL: _shouldInteractWithURL,
							  shouldInteractWithTextAttachment: _shouldInteractWithTextAttachment)

			disposable.ended
				.observe(on: UIScheduler())
				.observeCompleted { proxy.stopListening() }

		}
		.start(on: UIScheduler())
		.take(during: base.lifetime)

	}

	/// User iteraction events sent by TextView.
	///
	/// Forwards events on main queue.
	/// - Warning: UITextView's delegate will be set.
	///
	/// - Parameter events: Events to listen to
	/// - Returns: A SignalProducer of events.
	@available(iOS, introduced: 7.0, deprecated: 10.0)
	public func editEvents(_ events: UITextView.EditEvent,
						   shouldStartEditing: (() -> Bool)? = nil,
						   shouldEndEditing: (() -> Bool)? = nil,
						   shouldChangeText: ((_ range: NSRange, _ replacement: String) -> Bool)? = nil,
						   shouldInteractWithURL: ((_ URL: URL, _ range: NSRange) -> Bool)? = nil,
						   shouldInteractWithTextAttachment: ((_ textAttachment: NSTextAttachment, _ range: NSRange) -> Bool)? = nil) -> SignalProducer<UITextView.EditEvent, NoError> {

		return SignalProducer { [weak base] observer, disposable in

			guard let base = base else {
				observer.sendCompleted()
				return
			}

			let action: (UITextView.EditEvent) -> Void = { event in
				observer.send(value: event)
			}

			var _shouldInteractWithURL: ((_ URL: URL, _ range: NSRange, _ interaction: Any?) -> Bool)?
			if let shouldInteractWithURL = shouldInteractWithURL {
				_shouldInteractWithURL = { URL, range, _ in shouldInteractWithURL(URL, range) }
			}

			var _shouldInteractWithTextAttachment: ((_ textAttachment: NSTextAttachment, _ range: NSRange, _ interaction: Any?) -> Bool)?
			if let shouldInteractWithTextAttachment = shouldInteractWithTextAttachment {
				_shouldInteractWithTextAttachment = { textAttachment, range, _ in shouldInteractWithTextAttachment(textAttachment, range) }
			}

			let proxy = Proxy(textView: base,
							  events: events,
							  action: action,
							  shouldStartEditing: shouldStartEditing,
							  shouldEndEditing: shouldEndEditing,
							  shouldChangeText: shouldChangeText,
							  shouldInteractWithURL: _shouldInteractWithURL,
							  shouldInteractWithTextAttachment: _shouldInteractWithTextAttachment)

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

		if #available(iOS 10.0, *) {
			return editEvents(.editingChange,
							  shouldInteractWithURL: { _, _, _ in return true })
				.filterMap { [weak base] _ in base?.text }
		} else {
			return editEvents(.editingChange,
							  shouldInteractWithURL: { _, _ in return true })
				.filterMap { [weak base] _ in base?.text }
		}

	}

	/// TextView's current attributed text.
	///
	/// Forwards events on main queue.
	/// - Warning: UITextView's delegate will be set.
	public var attributedText: SignalProducer<NSAttributedString, NoError> {

		if #available(iOS 10.0, *) {
			return editEvents(.editingChange,
							  shouldInteractWithURL: { _, _, _ in return true })
				.filterMap { [weak base] _ in base?.attributedText }
		} else {
			return editEvents(.editingChange,
							  shouldInteractWithURL: { _, _ in return true })
				.filterMap { [weak base] _ in base?.attributedText }
		}

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


	// MARK: Delegate Callbacks

	private let shouldStartEditing: (() -> Bool)?
	private let shouldEndEditing: (() -> Bool)?
	private let shouldChangeText: ((_ range: NSRange, _ replacement: String) -> Bool)?
	private let shouldInteractWithURL: ((_ URL: URL, _ range: NSRange, _ interaction: Any?) -> Bool)?
	private let shouldInteractWithTextAttachment: ((_ textAttachment: NSTextAttachment, _ range: NSRange, _ interaction: Any?) -> Bool)?


	// MARK: - Initialize

	fileprivate init(textView: UITextView,
					 events: UITextView.EditEvent,
					 action: @escaping (UITextView.EditEvent) -> Void,
					 shouldStartEditing: (() -> Bool)?,
					 shouldEndEditing: (() -> Bool)?,
					 shouldChangeText: ((_ range: NSRange, _ replacement: String) -> Bool)?,
					 shouldInteractWithURL: ((_ URL: URL, _ range: NSRange, _ interaction: Any?) -> Bool)?,
					 shouldInteractWithTextAttachment: ((_ textAttachment: NSTextAttachment, _ range: NSRange, _ interaction: Any?) -> Bool)?) {

		self.textView = textView
		self.events = events
		self.action = action

		self.shouldStartEditing = shouldStartEditing
		self.shouldEndEditing = shouldEndEditing
		self.shouldChangeText = shouldChangeText
		self.shouldInteractWithURL = shouldInteractWithURL
		self.shouldInteractWithTextAttachment = shouldInteractWithTextAttachment

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
		if events.contains(.editingStart) {
			action(.editingStart)
		}
	}

	func textViewDidEndEditing(_ textView: UITextView) {
		if events.contains(.editingEnd) {
			action(.editingEnd)
		}
	}

	func textViewDidChange(_ textView: UITextView) {
		if events.contains(.editingChange) {
			action(.editingChange)
		}
	}

	func textViewDidChangeSelection(_ textView: UITextView) {
		if events.contains(.selectionChange) {
			action(.selectionChange)
		}
	}


	func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
		return shouldStartEditing?() ?? true
	}

	func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
		return shouldEndEditing?() ?? true
	}

	func textView(_ textView: UITextView,
				  shouldChangeTextIn range: NSRange,
				  replacementText text: String) -> Bool {
		return shouldChangeText?(range, text) ?? true
	}

	@available(iOS 10.0, *)
	func textView(_ textView: UITextView,
				  shouldInteractWith URL: URL,
				  in characterRange: NSRange,
				  interaction: UITextItemInteraction) -> Bool {
		return shouldInteractWithURL?(URL, characterRange, interaction) ?? true
	}

	@available(iOS 10.0, *)
	public func textView(_ textView: UITextView,
						 shouldInteractWith textAttachment: NSTextAttachment,
						 in characterRange: NSRange,
						 interaction: UITextItemInteraction) -> Bool {
		return shouldInteractWithTextAttachment?(textAttachment, characterRange, interaction) ?? true
	}

	@available(iOS, introduced: 7.0, deprecated: 10.0, message: "Use textView:shouldInteractWithURL:inRange:forInteractionType: instead")
	func textView(_ textView: UITextView,
				  shouldInteractWith URL: URL,
				  in characterRange: NSRange) -> Bool {
		return shouldInteractWithURL?(URL, characterRange, nil) ?? true
	}

	@available(iOS, introduced: 7.0, deprecated: 10.0, message: "Use textView:shouldInteractWithTextAttachment:inRange:forInteractionType: instead")
	func textView(_ textView: UITextView,
				  shouldInteractWith textAttachment: NSTextAttachment,
				  in characterRange: NSRange) -> Bool {
		return shouldInteractWithTextAttachment?(textAttachment, characterRange, nil) ?? true
	}

}
