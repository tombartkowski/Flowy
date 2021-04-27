//
//  FlowEventSourcable.swift
//  Flowy
//
//  Created by Tomasz Bartkowski on 07/04/2021.
//
import RxSwift

public protocol FlowEventsSourceable {
    var events: PublishSubject<FlowEvent> { get }
}
