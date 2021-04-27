//
//  ViewController+RxDismissed.swift
//  Textail
//
//  Created by Tomasz Bartkowski on 08/04/2021.
//

import RxCocoa
import RxSwift

public extension Reactive where Base: UIViewController {
    var dismissed: ControlEvent<Void> {
        let dismissed = sentMessage(#selector(Base.viewDidDisappear))
            .filter { [weak base] _ in base?.isBeingDismissed ?? true }
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
            

        return ControlEvent(
            events: Observable.merge(
                dismissed,
                movedToParent,
                navigationControllerDismissed,
                tabBarControllerDismissed
            )
        )
    }
}
