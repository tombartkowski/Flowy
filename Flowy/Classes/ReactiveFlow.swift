//
//  RxFlowable.swift

//
//  Created by Tomasz Bartkowski on 21/04/2021.
//  Copyright © 2021 Tomasz Bartkowski. All rights reserved.
//

import RxSwift

public final class ReactiveFlow {
    // MARK: Lifecycle

    public init(
        rootFlow: Flow,
        eventsSource: FlowEventsSourceable = DefaultEventsSource.shared
    ) {
        self.rootFlow = rootFlow
        self.eventsSource = eventsSource
    }

    // MARK: Public

    public static var defaultEventsSource: FlowEventsSourceable {
        DefaultEventsSource.shared
    }

    public func startFlow() {
        appCoordinator = AppFlowCoordinator(
            rootFlow: rootFlow,
            eventsSource: eventsSource,
            flowFactory: registeredFlows
        )

        appCoordinator
            .start()
            .subscribe()
            .disposed(by: disposeBag)
    }

    public func registerFlow(_ flowType: FlowType, name: String, factory: @escaping (RootPresentable) -> Flow) {
        let registrationKey = String(describing: flowType.self) + name
        registerFlow(for: registrationKey, factory: factory)
    }

    public func registerFlow(_ flowType: FlowType, factory: @escaping (RootPresentable) -> Flow) {
        registerFlow(for: String(describing: flowType.self), factory: factory)
    }

    // MARK: Internal

    internal var registeredFlows = FlowFactory()

    // MARK: Private

    private var appCoordinator: AppFlowCoordinator!
    private let rootFlow: Flow
    private let eventsSource: FlowEventsSourceable
    private let disposeBag = DisposeBag()

    private func registerFlow(for key: String, factory: @escaping (RootPresentable) -> Flow) {
        registeredFlows[key] = factory
    }
}
