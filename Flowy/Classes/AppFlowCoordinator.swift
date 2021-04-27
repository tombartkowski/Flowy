//
//  AppFlowCoordinator.swift

//
//  Created by Tomasz Bartkowski on 23/04/2021.
//  Copyright © 2021 Tomasz Bartkowski. All rights reserved.
//

import RxSwift

class AppFlowCoordinator: FlowCoordinator {
    // MARK: Lifecycle

    init(rootFlow: Flow, eventsSource: FlowEventsSourceable, flowFactory: FlowFactory) {
        self.rootFlow = rootFlow
        super.init(flow: DefaultFlow(), eventsSource: eventsSource, flowFactory: flowFactory)
    }

    // MARK: Internal

    override func start() -> Single<FlowEvent?> {
        let rootCoordinator = coordinator(for: rootFlow)
        transition(to: rootCoordinator)
            .subscribe()
            .disposed(by: disposeBag)

        return .never()
    }

    // MARK: Private

    private let rootFlow: Flow
}
