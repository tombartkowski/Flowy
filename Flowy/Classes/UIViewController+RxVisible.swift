//
//  UIViewController+RxVisible.swift
//
//  Created by Tomasz Bartkowski on 23/04/2021.
//  Copyright © 2021 Tomasz Bartkowski. All rights reserved.
//

import RxCocoa
import RxSwift

public extension Reactive where Base: UIViewController {
    var visible: Observable<Bool> {
        let viewDidAppearObservable = sentMessage(#selector(Base.viewDidAppear)).map { _ in true }
        let viewDidDisappearObservable = sentMessage(#selector(Base.viewDidDisappear)).map { _ in false }

        //If presented ViewController was presented as a sheet then Presenting ViewController will not
        //recieve `viewDidAppear` or `viewDidDisappear`, but still will be unable to perform any tansitions.
        let presentedModally = sentMessage(#selector(Base.present(_:animated:completion:))).map { _ in false }
        let dismissedModally = sentMessage(#selector(Base.dismiss(animated:completion:))).map { _ in true }

        return Observable.merge(
            viewDidAppearObservable,
            viewDidDisappearObservable,
            presentedModally,
            dismissedModally
        )
        .startWith(true)
    }
}
