//
//  Flowy.swift
//
//  Created by Tomasz Bartkowski on 21/04/2021.
//  Copyright © 2021 Tomasz Bartkowski. All rights reserved.
//

import RxSwift

/// `Flowy` is the entry class where you can register your Flows, provide an events source and start the coordination.
public final class Flowy {
    // MARK: Lifecycle

    /// Default initializer for the `Flowy` class.
    ///
    /// - Parameters:
    ///   - rootFlow:     `Flow` to start the coordination with.
    ///   - eventsSource: `FlowEventsSourceable` used to source `FlowEvent` that will drive the coordination.
    ///                   `DefaultEventsSource.shared` by default.
    public init(
        rootFlow: Flow,
        eventsSource: FlowEventsSourceable = DefaultEventsSource.shared
    ) {
        self.rootFlow = rootFlow
        self.eventsSource = eventsSource
    }

    // MARK: Public

    /// Default, singleton implementation of the `FlowEventsSourceable` protocol.
    public static var defaultEventsSource: FlowEventsSourceable {
        DefaultEventsSource.shared
    }

    /// Starts the coordination process.
    /// - Warning: All Flows should be registered before calling this method using `registerFlow(_ flowType: factory:)`.
    public func start() {
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

    /// Registers factory closure for the given Flow type that will be used to create the next Flow to transition to during runtime.
    ///
    /// - Parameters:
    ///   - flowType: `Flow.Type` of your `Flow` subclass to create in the factory closure.
    ///   - factory:  The closure to specify how the flow type should be created.
    ///               It is invoked during transition to the specified `Flow`.
    ///               It takes a `Presentable` which is a parent presentable for this `Flow`.
    public func registerFlow<FlowSubclass: Flow>(
        _ flowType: FlowSubclass.Type,
        factory: @escaping (RootPresentable) -> FlowSubclass
    ) {
        registerFlow(for: String(describing: flowType.self), factory: factory)
    }

    /// Registers factory closure for a given Flow type and transition key that will be used to create the provided Flow to transition to during runtime.
    ///
    /// - Parameters:
    ///   - flowType:      `Flow.Type` of your `Flow` subclass to create in the factory closure.
    ///   - transitionKey: The key to differentiate multiple closures for one `Flow.Type`.
    ///                    Value will be compared with  `FlowEvent.transitionKey` to pick the correct factory closure.
    ///   - factory:       The closure to specify how the flow type should be created.
    ///                    It is invoked during transition to the specified `Flow`.
    ///                    It takes a `Presentable` which is a parent presentable for this `Flow`.
    public func registerFlow<FlowSubclass: Flow>(
        _ flowType: FlowSubclass.Type,
        transitionKey: String,
        factory: @escaping (RootPresentable) -> FlowSubclass
    ) {
        let registrationKey = String(describing: flowType.self) + transitionKey
        registerFlow(for: registrationKey, factory: factory)
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
