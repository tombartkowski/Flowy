//
//  Presentable.swift
//  Flowy
//
//  Created by Tomasz Bartkowski on 05/04/2021.
//
import RxSwift

// MARK: - Presentable

public protocol Presentable: AnyObject, AutoMockable {
    func present(
        _ presentable: Presentable,
        presentationMode: Flow.PresentationMode,
        animated: Bool,
        completion: (() -> Void)?
    ) throws
    func dismiss(_ presentable: Presentable, animated: Bool, completion: (() -> Void)?) throws
    var rx_dismissed: Single<Void> { get }
    var rx_visible: Observable<Bool> { get }
}

// MARK: - AutoMockable

public protocol AutoMockable {}
