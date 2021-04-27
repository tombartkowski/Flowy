//
//  TabBarFlow.swift

//
//  Created by Tomasz Bartkowski on 22/04/2021.
//  Copyright © 2021 Tomasz Bartkowski. All rights reserved.
//

import UIKit.UITabBarController

open class TabBarFlow: Flow {
    // MARK: Lifecycle

    convenience init(tabBarController: UITabBarController = UITabBarController(), presentingPresentable: Presentable? = nil, flows: [Flow]) {
        self.init(presentableParent: presentingPresentable, presentable: tabBarController)
        childFlows = flows
    }
    
    required public init(presentableParent: Presentable?, presentable: Presentable) {
        super.init(presentableParent: presentableParent, presentable: presentable)
        self.tabBarController = presentable as! UITabBarController
    }
    
    // MARK: Open

    open var tabBarController: UITabBarController = UITabBarController()

    override open func present(completion: (() -> Void)? = nil) throws {
        if let presentableParent = presentableParent {
            try presentableParent.present(
                tabBarController,
                presentationMode: presentationMode,
                animated: animatePresent,
                completion: completion
            )
        } else {
            try tabBarController.present(
                tabBarController,
                presentationMode: .windowRoot,
                animated: false,
                completion: completion
            )
        }
    }

    // MARK: Public

    public final var childFlows: [Flow] = []
}
