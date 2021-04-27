//
//  DefaultFlow.swift
//
//  Created by Tomasz Bartkowski on 24/04/2021.
//  Copyright © 2021 Tomasz Bartkowski. All rights reserved.
//

import UIKit.UIViewController

public class DefaultFlow: Flow {
    public convenience init(parentPresentable: Presentable? = nil, presentable: Presentable = UIViewController()) {
        self.init(presentableParent: parentPresentable, presentable: presentable)
    }

    public required init(presentableParent: Presentable?, presentable: Presentable) {
        super.init(presentableParent: presentableParent, presentable: presentable)
    }
}
