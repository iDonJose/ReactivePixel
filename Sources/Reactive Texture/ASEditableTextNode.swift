//
//  ASEditableTextNode.swift
//  ReactivePixel-iOS
//
//  Created by José Donor on 17/11/2018.
//

import AsyncDisplayKit
import ReactiveSwift
import Result



extension Reactive where Base: ASEditableTextNode {

	/// User iteraction events sent by TextView.
	///
	/// Forwards events on main queue.
	/// - Warning: ASEditableTextNode's delegate will be set.
	///
	/// - Parameter events: Events to listen to
	/// - Returns: A SignalProducer of events.
	public func editEvents(_ events: ASEditableTextNode.Event) -> SignalProducer<ASEditableTextNode.Event, NoError> {

		return SignalProducer { [weak base] observer, disposable in

			guard let base = base else {
				observer.sendCompleted()
				return
			}

			let proxy = Proxy(editableText: base, events: events) { event in
				observer.send(value: event)
			}

			disposable.ended
				.observe(on: UIScheduler())
				.observeCompleted { proxy.stopListening() }

		}
		.start(on: UIScheduler())
		.take(during: base.lifetime)

	}

	/// EditableText's current text.
	///
	/// Forwards events on main queue.
	/// - Warning: ASEditableTextNode's delegate will be used.
	public var text: SignalProducer<String, NoError> {

		return attributedText.map { $0.string }
	}

	/// EditableText's current attributed text.
	///
	/// Forwards events on main queue.
	/// - Warning: ASEditableTextNode's delegate will be used.
	public var attributedText: SignalProducer<NSAttributedString, NoError> {

		return editEvents(.editingChange)
			.filterMap { [weak base] _ in base?.attributedText }
	}

}


extension ASEditableTextNode {

	/// Event that is produced by listening to ASEditableTextNodeDelegate
	public struct Event: OptionSet {

		public let rawValue: UInt

		public static let editingStart = Event(rawValue: 1 << 0)
		public static let editingEnd = Event(rawValue: 1 << 1)
		public static let editingChange = Event(rawValue: 1 << 2)
		public static let selectionChange = Event(rawValue: 1 << 3)

		public static let all: Event = [.editingStart, .editingEnd, .editingChange, .selectionChange]

		// MARK: - Initialize

		public init(rawValue: UInt) { self.rawValue = rawValue }

	}

}


private final class Proxy: NSObject, ASEditableTextNodeDelegate {

	/// Targeted ASEditableTextNode
	private weak var editableText: ASEditableTextNode?
	/// Events to listen to
	private let events: ASEditableTextNode.Event
	/// Action to trigger on events
	private let action: (ASEditableTextNode.Event) -> Void


	// MARK: - Initialize

	fileprivate init(editableText: ASEditableTextNode,
					 events: ASEditableTextNode.Event,
					 action: @escaping (ASEditableTextNode.Event) -> Void) {

		self.editableText = editableText
		self.events = events
		self.action = action
		super.init()

		editableText.delegate = self

		/// Simulates an edit change for initial value
		if events.contains(.editingChange) {
			action(.editingChange)
		}

	}

	deinit {
		stopListening()
	}


	fileprivate func stopListening() {
		editableText?.delegate = nil
	}


	// MARK: - ASEditableTextNodeDelegate

	func editableTextNodeDidBeginEditing(_ editableTextNode: ASEditableTextNode) {
		action(.editingStart)
	}

	func editableTextNodeDidFinishEditing(_ editableTextNode: ASEditableTextNode) {
		action(.editingEnd)
	}

	func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
		action(.editingChange)
	}

	func editableTextNodeDidChangeSelection(_ editableTextNode: ASEditableTextNode,
											fromSelectedRange: NSRange,
											toSelectedRange: NSRange,
											dueToEditing: Bool) {
		action(.selectionChange)
	}

}
