//
//  TabBarFlowCoordinator.swift
//
//  Created by Tomasz Bartkowski on 24/04/2021.
//  Copyright © 2021 Tomasz Bartkowski. All rights reserved.
//

import RxSwift

class TabBarFlowCoordinator: FlowCoordinator {
    override func start() -> Single<FlowEvent?> {
        guard let flow = self.flow as? TabBarFlow else { return .never() }
        Observable.merge(
            flow.childFlows
                .compactMap { coordinator(for: $0) }
                .map { transition(to: $0).asObservable() }
        )
        .subscribe()
        .disposed(by: disposeBag)

        return super.start()
    }
}
