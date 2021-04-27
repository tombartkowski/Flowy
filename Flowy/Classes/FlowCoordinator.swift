//
//  FlowCoordinator.swift
//
//  Created by Tomasz Bartkowski on 22/04/2021.
//  Copyright © 2021 Tomasz Bartkowski. All rights reserved.
//

import Foundation.NSUUID
import RxSwift
import RxSwiftExt

class FlowCoordinator {
    // MARK: Lifecycle

    init(
        flow: Flow,
        eventsSource: FlowEventsSourceable,
        flowFactory: FlowFactory
    ) {
        self.flow = flow
        self.eventsSource = eventsSource
        self.flowFactory = flowFactory
    }

    // MARK: Internal

    final let flow: Flow
    final let identifier = UUID()
    fileprivate(set) var childFlowCoordinators = [UUID: FlowCoordinator]()

    final let eventsSource: FlowEventsSourceable
    final let flowFactory: FlowFactory

    final let disposeBag = DisposeBag()

    func start() -> Single<FlowEvent?> {
        try? flow.present()

        eventsSource.events
            .compactMap { [weak self] flowEvent in self?.nextFlowCoordinator(for: flowEvent) }
            .withLatestFrom(flow.presentable.rx_visible) { ($0, $1) }
            .filterMap { $0.1 ? .map($0.0) : .ignore }
            .flatMap { [weak self] nextCoordinator in self?.transition(to: nextCoordinator) ?? .never() }
            .subscribe()
            .disposed(by: disposeBag)

        let flowResult = eventsSource.events
            .withLatestFrom(flow.presentable.rx_visible) { ($0, $1) }
            .filterMap { $0.1 ? .map($0.0) : .ignore }
            .filter { [weak self] event in self?.flow.dismissingEvents.contains { $0.isEqualTo(event) } ?? false }
            .take(1)
            .do(onNext: { [weak self] _ in try? self?.flow.dismiss() })
            .map { event -> FlowEvent? in event }
            .startWith(nil)

        return flow.presentable.rx_dismissed.asObservable()
            .merge(with: flow.presentableParent?.rx_dismissed.asObservable() ?? .never())
            .withLatestFrom(flowResult)
            .take(1)
            .asSingle()
            .do(afterSuccess: { [weak self] event in
                guard let event = event else { return }
                self?.eventsSource.events.onNext(event)
            })
    }

    func transition(to flowCoordinator: FlowCoordinator) -> Single<FlowEvent?> {
        store(flowCoordinator)
        return flowCoordinator.start()
            .do(onSuccess: { [weak self] _ in self?.free(flowCoordinator) })
    }

    func free(_ flowCoordinator: FlowCoordinator) {
        flowCoordinator.childFlowCoordinators.keys.forEach { uuid in
            if let childFlowCoordinator = flowCoordinator.childFlowCoordinators[uuid] {
                flowCoordinator.free(childFlowCoordinator)
            }
        }
        childFlowCoordinators[flowCoordinator.identifier] = nil
    }

    func coordinator(for flow: Flow) -> FlowCoordinator {
        if let flow = flow as? TabBarFlow {
            return TabBarFlowCoordinator(flow: flow, eventsSource: eventsSource, flowFactory: flowFactory)
        }
        return FlowCoordinator(flow: flow, eventsSource: eventsSource, flowFactory: flowFactory)
    }

    // MARK: Fileprivate

    fileprivate func store(_ flowCoordinator: FlowCoordinator) {
        childFlowCoordinators[flowCoordinator.identifier] = flowCoordinator
    }

    // MARK: Private

    private func nextFlowCoordinator(for flowEvent: FlowEvent) -> FlowCoordinator? {
        guard let flowType = flow.nextFlowType(for: flowEvent) else { return nil }

        let factoryKey = String(describing: flowType.self) + (flowEvent.flowName ?? "")
        guard let flowFactoryClosure = flowFactory[factoryKey] else { return nil }

        let nextFlow = flowFactoryClosure(flow.presentable)
        return coordinator(for: nextFlow)
    }
}
