//
//  ViewController+RxDismissed.swift
//  Flowy
//
//  Created by Tomasz Bartkowski on 08/04/2021.
//

import RxCocoa
import RxSwift

public extension Reactive where Base: UIViewController {
    var dismissed: ControlEvent<Void> {
        let willDismiss = sentMessage(#selector(Base.viewWillDisappear(_:)))
            .compactMap { _ in (base.presentingViewController, base.modalPresentationStyle) }
            .startWith((nil, .fullScreen))

        let dismissed = sentMessage(#selector(Base.viewDidDisappear))
            .filter { [weak base] _ in base?.isBeingDismissed ?? true }
            
            .withLatestFrom(willDismiss)
            .do(onNext: { parent, style in
                if
                    #available(iOS 13.0, *),
                    style == .automatic ||
                    style == .pageSheet ||
                    style == .formSheet,
                    parent != nil
                {
                    var recieverViewController: UIViewController?
                    if let tabBar = parent as? UITabBarController {
                        if let navigationController = tabBar.selectedViewController as? UINavigationController {
                            recieverViewController = navigationController.topViewController
                        } else {
                            recieverViewController = tabBar.selectedViewController
                        }
                    } else if let navigationController = parent as? UINavigationController {
                        recieverViewController = navigationController.topViewController
                    } else {
                        recieverViewController = parent
                    }
                    recieverViewController?.viewDidAppear(false)
                }
            })
            .map { _ in () }

        let movedToParent = sentMessage(#selector(Base.didMove))
            .filter { !($0.first is UIViewController) }
            .map { _ in () }

        let navigationControllerDismissed = base.navigationController?
            .rx
            .dismissed
            .asObservable() ?? .empty()

        let tabBarControllerDismissed = base.tabBarController?
            .rx
            .dismissed
            .asObservable() ?? .empty()

        let dismissedEvents = Observable.merge(
            dismissed,
            movedToParent,
            navigationControllerDismissed,
            tabBarControllerDismissed
        )

        return ControlEvent(
            events: dismissedEvents
        )
    }
}
