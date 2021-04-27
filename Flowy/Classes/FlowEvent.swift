//
//  FlowEvent.swift
//
//  Created by Tomasz Bartkowski on 21/04/2021.
//  Copyright © 2021 Tomasz Bartkowski. All rights reserved.
//

// MARK: - FlowEvent

public protocol FlowEvent {
    func isEqualTo(_ other: FlowEvent) -> Bool
    var transitionKey: String? { get }
}

public extension FlowEvent where Self: Equatable {
    func isEqualTo(_ other: FlowEvent) -> Bool {
        return (other as? Self).flatMap { $0 == self } ?? false
    }
}

public extension FlowEvent {
    var transitionKey: String? {
        return nil
    }
}
