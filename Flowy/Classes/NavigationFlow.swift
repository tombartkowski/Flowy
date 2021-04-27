//
//  NavigationFlow.swift
//
//  Created by Tomasz Bartkowski on 22/04/2021.
//  Copyright © 2021 Tomasz Bartkowski. All rights reserved.
//

import UIKit.UINavigationController

open class NavigationFlow: Flow {
    // MARK: Lifecycle

    public convenience init(
        navigationController: UINavigationController = UINavigationController(),
        presentingPresentable: Presentable? = nil,
        presentable: Presentable
    ) {
        self.init(presentableParent: navigationController, presentable: presentable)
        self.navigationController = navigationController
        self.presentingPresentable = presentingPresentable
    }

    public required init(presentableParent: Presentable?, presentable: Presentable) {
        super.init(presentableParent: presentableParent, presentable: presentable)
    }

    // MARK: Open

    open var navigationController = UINavigationController()

    override open func present(completion: (() -> Void)? = nil) throws {
        if let presentingPresentable = presentingPresentable {
            try presentingPresentable.present(
                navigationController,
                presentationMode: presentationMode,
                animated: animatePresent,
                completion: completion
            )
        } else {
            try navigationController.present(
                navigationController,
                presentationMode: .windowRoot,
                animated: false,
                completion: completion
            )
        }
        guard let viewController = presentable as? UIViewController else { return }
        navigationController.pushViewController(viewController, animated: false)
    }

    // MARK: Private

    private var presentingPresentable: Presentable?
}
