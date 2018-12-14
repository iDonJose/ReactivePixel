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
	public func editEvents(_ events: ASEditableTextNode.Event,
						   shouldStartEditing: (() -> Bool)? = nil,
						   shouldChangeText: ((_ range: NSRange, _ replacement: String) -> Bool)? = nil,
						   didChangeSelection: ((_ oldRange: NSRange, _ newRange: NSRange, _ dueToEditing: Bool) -> Void)? = nil) -> SignalProducer<ASEditableTextNode.Event, NoError> {

		return SignalProducer { [weak base] observer, disposable in

			guard let base = base else {
				observer.sendCompleted()
				return
			}

			let action: (ASEditableTextNode.Event) -> Void = { event in
				observer.send(value: event)
			}

			let proxy = Proxy(editableText: base,
							  events: events,
							  action: action,
							  shouldStartEditing: shouldStartEditing,
							  shouldChangeText: shouldChangeText,
							  didChangeSelection: didChangeSelection)

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


	// MARK: Delegate Callbacks

	private let shouldStartEditing: (() -> Bool)?
	private let shouldChangeText: ((_ range: NSRange, _ replacement: String) -> Bool)?
	private let didChangeSelection: ((_ oldRange: NSRange, _ newRange: NSRange, _ dueToEditing: Bool) -> Void)?


	// MARK: - Initialize

	fileprivate init(editableText: ASEditableTextNode,
					 events: ASEditableTextNode.Event,
					 action: @escaping (ASEditableTextNode.Event) -> Void,
					 shouldStartEditing: (() -> Bool)?,
					 shouldChangeText: ((_ range: NSRange, _ replacement: String) -> Bool)?,
					 didChangeSelection: ((_ oldRange: NSRange, _ newRange: NSRange, _ dueToEditing: Bool) -> Void)?) {

		self.editableText = editableText
		self.events = events
		self.action = action

		self.shouldStartEditing = shouldStartEditing
		self.shouldChangeText = shouldChangeText
		self.didChangeSelection = didChangeSelection

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
		if events.contains(.editingStart) {
			action(.editingStart)
		}
	}

	func editableTextNodeDidFinishEditing(_ editableTextNode: ASEditableTextNode) {
		if events.contains(.editingEnd) {
			action(.editingEnd)
		}
	}

	func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
		if events.contains(.editingChange) {
			action(.editingChange)
		}
	}


	func editableTextNodeShouldBeginEditing(_ editableTextNode: ASEditableTextNode) -> Bool {
		return shouldStartEditing?() ?? true
	}

	func editableTextNode(_ editableTextNode: ASEditableTextNode,
						  shouldChangeTextIn range: NSRange,
						  replacementText text: String) -> Bool {
		return shouldChangeText?(range, text) ?? true
	}

	func editableTextNodeDidChangeSelection(_ editableTextNode: ASEditableTextNode,
											fromSelectedRange start: NSRange,
											toSelectedRange end: NSRange,
											dueToEditing: Bool) {
		didChangeSelection?(start, end, dueToEditing)
		if events.contains(.selectionChange) {
			action(.selectionChange)
		}
	}

}
