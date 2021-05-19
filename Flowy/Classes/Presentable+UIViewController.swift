//
//  Presentable+ViewController.swift
//  Flowy
//
//  Created by Tomasz Bartkowski on 08/04/2021.
//

import RxCocoa
import RxSwift

// MARK: - PresentingError

public enum PresentingError: Error {
    case presentableNotUIViewController
}

// MARK: - TypedPresentable

public enum TypedPresentable {
    case navigationController(UINavigationController)
    case tabBarController(UITabBarController)
    case `default`(UIViewController)

    // MARK: Internal

    var viewController: UIViewController {
        switch self {
        case let .navigationController(vc):
            return vc
        case let .tabBarController(vc):
            return vc
        case let .default(vc):
            return vc
        }
    }
}

public extension Presentable where Self: UIViewController {
    var rx_visible: Observable<Bool> {
        return rx.visible
    }

    var rx_dismissed: Single<Void> {
        return rx.dismissed.take(1).asSingle()
    }

    func present(
        _ presentable: Presentable,
        presentationMode: Flow.PresentationMode,
        animated: Bool,
        completion: (() -> Void)?
    ) throws {
        guard let presentable = presentable as? UIViewController else {
            throw PresentingError.presentableNotUIViewController
        }

        var typedParent: TypedPresentable = .default(self)
        switch self {
        case is UINavigationController:
            typedParent = .navigationController(self as! UINavigationController)
        case is UITabBarController:
            typedParent = .tabBarController(self as! UITabBarController)
        default:
            break
        }

        var typedPresentable: TypedPresentable = .default(presentable)
        switch presentable {
        case is UINavigationController:
            typedPresentable = .navigationController(presentable as! UINavigationController)
        case is UITabBarController:
            typedPresentable = .tabBarController(presentable as! UITabBarController)
        default:
            break
        }

        present(
            typedPresentable,
            parentPresentable: typedParent,
            presentationMode: presentationMode,
            animated: animated,
            completion: completion
        )
    }

    func dismiss(
        _ presentable: Presentable,
        animated: Bool,
        completion: (() -> Void)?
    ) throws {
        guard let presentable = presentable as? UIViewController else {
            throw PresentingError.presentableNotUIViewController
        }

        var typedParent: TypedPresentable = .default(self)
        switch self {
        case is UINavigationController:
            typedParent = .navigationController(self as! UINavigationController)
        case is UITabBarController:
            typedParent = .tabBarController(self as! UITabBarController)
        default:
            break
        }
        dismiss(
            presentable,
            parentPresentable: typedParent,
            animated: animated,
            completion
        )
    }

    private func present(
        _ presentable: TypedPresentable,
        parentPresentable: TypedPresentable,
        presentationMode: Flow.PresentationMode,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        switch (parentPresentable, presentable, presentationMode) {
        case (_, _, .windowRoot):
            let window = UIApplication.shared.delegate?.window
            window??.rootViewController = presentable.viewController
            window??.makeKeyAndVisible()
            completion?()
        case (_, _, .modal):
            parentPresentable.viewController.present(
                presentable.viewController,
                animated: animated,
                completion: completion
            )
        case let (.navigationController(parent), .navigationController(presentable), _):
            parent.present(presentable, animated: animated, completion: completion)
        case let (.tabBarController(parent), .tabBarController(presentable), _):
            parent.present(presentable, animated: animated, completion: completion)
        case let (.tabBarController(parent), _, _):
            var viewControllers = parent.viewControllers ?? []
            viewControllers.append(presentable.viewController)
            parent.viewControllers = viewControllers
            completion?()
        case let (.navigationController(parent), _, _):
            parent.pushViewController(presentable.viewController, animated: animated)
        default:
            parentPresentable.viewController.present(
                presentable.viewController,
                animated: animated,
                completion: completion
            )
        }
    }

    private func dismiss(
        _ presentable: UIViewController,
        parentPresentable: TypedPresentable,
        animated: Bool,
        _ completion: (() -> Void)? = nil
    ) {
        switch (parentPresentable, presentable) {
        case let (.navigationController(parent), _):
            if
                parent.viewControllers.contains(presentable),
                parent.viewControllers.count > 1
            {
//                _ = presentable.rx.dismissed.subscribe { _ in
//                    completion?()
//                }
                parent.popViewController(animated: animated)

            } else {
                parent.dismiss(animated: animated, completion: completion)
            }
        case let (.tabBarController(parent), _):
            if
                let childrenViewControllers = parent.viewControllers,
                let index = childrenViewControllers.firstIndex(of: presentable)
            {
                var viewControllers = childrenViewControllers
                viewControllers.remove(at: index)
                parent.setViewControllers([], animated: false)
                completion?()
            } else {
                parent.dismiss(animated: animated, completion: completion)
            }
        default:
            parentPresentable.viewController.dismiss(animated: animated, completion: completion)
        }
    }
}
