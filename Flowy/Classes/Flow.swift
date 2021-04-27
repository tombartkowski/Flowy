//
//  Flow.swift
//
//  Created by Tomasz Bartkowski on 21/04/2021.
//  Copyright © 2021 Tomasz Bartkowski. All rights reserved.
//

import UIKit.UIViewController

/// `Flow` is the common superclass for all flow types and provides common transition, presentation and dismissal logic, that you can override.
open class Flow: NSObject {
    // MARK: Lifecycle

    /// Default initializer for the `Flow` superclass.
    ///
    /// - Parameters:
    ///   - presentableParent: `Presentable` of the `Flow` that transitions to this instance.
    ///   - presentable:       `Presentable` that will be presented for this Flow.
    public required init(presentableParent: Presentable?, presentable: Presentable) {
        self.presentableParent = presentableParent
        self.presentable = presentable
    }

    // MARK: Open

    /// `Presentable` of the Flow that performed the transition to this instance.
    open weak var presentableParent: Presentable?

    /// `Presentable` that is visible after transition to this instance.
    open var presentable: Presentable

    /// Contains every `FlowEvent` that will trigger the dismissal.
    ///
    /// The first event that resulted in dismissal will be passed back to the parent `Flow`.
    ///
    /// If the parent `Flow` returns a valid `FlowType` from `nextFlowType(for flowEvent: FlowEvent)` for the dismissing event
    /// it will transition to that `FlowType`.
    ///
    /// Empty by default.
    open var dismissingEvents: [FlowEvent] {
        [FlowEvent]()
    }

    /// Determines if the presentation should animate.
    ///
    /// This includes the default system modal transition and `UINavigationController` push animation.
    open var animatePresent: Bool { true }
    
    /// Determines if the dismissal should animate.
    ///
    /// This includes the default system modal transition and `UINavigationController` pop animation.
    open var animateDismiss: Bool { true }

    
    /// Determines how the `presentable` should be presented.
    ///
    /// The behaviour for each mode is defined as follows:
    /// * `.default` - adapts to the default presentation mode of the `presentableParent`:
    ///     * `UINavigationController` will push the `presentable`,
    ///     * `UITabBarController` will append the `presentable` to the `TabBar`,
    ///     * regular `UIViewController` subclass  will use the default `present(_:animated:completion:)`.
    /// * `.modal` - will always use the `present(_:animated:completion:)`,
    /// * `.windowRoot` - makes `presentable` a `rootViewController` of the current `UIWindow` with no animation.
    open var presentationMode: PresentationMode {
        .default
    }

    open func nextFlowType(for _: FlowEvent) -> FlowType? {
        return nil
    }

    open func present(completion: (() -> Void)? = nil) throws {
        if let presentableParent = presentableParent {
            try presentableParent.present(
                presentable,
                presentationMode: presentationMode,
                animated: animatePresent,
                completion: completion
            )
        } else {
            try presentable.present(
                presentable,
                presentationMode: .windowRoot,
                animated: false,
                completion: completion
            )
        }
    }

    open func dismiss(completion: (() -> Void)? = nil) throws {
        try presentableParent?.dismiss(
            presentable,
            animated: animateDismiss,
            completion: completion
        )
    }
}
