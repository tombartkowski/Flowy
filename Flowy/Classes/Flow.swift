//
//  Flow.swift
//
//  Created by Tomasz Bartkowski on 21/04/2021.
//  Copyright © 2021 Tomasz Bartkowski. All rights reserved.
//

import UIKit.UIViewController

open class Flow {
    // MARK: Lifecycle

    public required init(presentableParent: Presentable?, presentable: Presentable) {
        self.presentableParent = presentableParent
        self.presentable = presentable
    }

    // MARK: Open

    open weak var presentableParent: Presentable?
    open var presentable: Presentable

    open var dismissingEvents: [FlowEvent] {
        [FlowEvent]()
    }

    open var animatePresent: Bool { true }
    open var animateDismiss: Bool { true }

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
