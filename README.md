<p align="center">
  <a href="https://raw.githubusercontent.com/tombartkowski/Flowy">
    <img src="logo.png" alt="Logo" width="150" height="140">
  </a>

  <h2 align="center"><b>Flowy</b></h2>

  <p align="center">
    Reactive & declarative event-driven coordination in Swift.
    <br />
    <br />
    <a href="#features">Features </a>
     • 
    <a href="#quick-example">Example</a>
     • 
    <a href="#usage">Usage</a>
     • 
    <a href="#installation">Installation</a>
  </p>
</p>

<p align="center">
    <a href="https://developer.apple.com/swift/"><img alt="Swift 5.2" src="https://img.shields.io/badge/swift-5.2-orange.svg?style=flat"></a>
    <a href="https://github.com/tombartkowski/Flowy/LICENSE"><img alt="License" src="https://img.shields.io/github/license/tombartkowski/Flowy"></a>
    <a href="https://github.com/tombartkowski/Flowy"><img alt="Build Status" src="https://img.shields.io/github/last-commit/tombartkowski/Flowy"></a>
</p>

<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#features">Features</a>
    </li>
    <li>
      <a href="#quick-example">Quick Example</a>
    </li>
    <li>
      <a href="#installation">Installation</a>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>

## Features

- :white_check_mark: Declarative - declare your Flows behaviour in one place,
- :white_check_mark: Reactive - no more imperative coordination thanks to `RxSwift`,
- :white_check_mark: Event-driven - emit flow events from anywhere and coordination will follow,
- :white_check_mark: Easier decoupling of views,
- :white_check_mark: Simple to get started.

## Quick Example

```swift
enum MyFlowEvent: FlowEvent {
  case detailRequired
}

class DetailFlow: Flow {}

class MasterFlow: Flow {
  func nextFlowType(for event: FlowEvent) -> FlowType? {
    if case event = MyFlowEvent.detailRequired {
      return DetailFlow.self
    }
    return nil
  }
}

let flowy = Flowy(rootFlow: MasterFlow())
flowy.registerFlow(DetailFlow.self) { root -> DetailFlow in
  DetailFlow(
    presentableParent: root,
    presentable: UIViewController()
  )
}

//This will perform a transition MasterFlow -> DetailFlow
DefaultEventsSource.shared.events.onNext(MyFlowEvent.detailRequired)
```

## Installation

### Requirements

- Deployment target iOS 10.0+
- Swift 5+
- Xcode 10+

#### CocoaPods

Flowy is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Flowy'
```

## Usage

### Basics

Flowy works with `Flows` and `FlowEvents`.

You can think of a `Flow` as a `UIViewController`, or rather an object that references it and the `UIViewController` that presented it.

Each `Flow` defines a map of `FlowEvents` to `Flow` which specifies which `Flow` to transition to on a given `FlowEvent`.
`Flow` also defines a list of `FlowEvents` that dissmis the `Flow` when emitted.

### Defining Flows

To create a basic `Flow` simply create a subclass of `Flow`.

```swift
import Flowy
class MasterDetail: Flow {
  override func nextFlowType(for event: FlowEvent) -> FlowType? {
    if case event = MyFlowEvent.detailRequired {
      return DetailFlow.self
    }
    return nil
  }

  override var presentationMode: Flow.PresentationMode {
    .modal
  }

  override var dismissingEvents: [FlowEvent] {
    [MyFlowEvent.masterDone]
  }
}
```

Example above will transition to `DetailFlow` when `.detailRequired` event gets emitted. It will also dismiss itself when `.masterDone` event is emitted. `presentationMode` specifies that this `Flow` should always be presented modally.

Flowy ships with `NavigationFlow` and `TabBarFlow` that handle the `UINavigationController` and `UITabBarController` navigation under the hood.

### Defining FlowEvents

To use Flowy you need to define at least one entity that conforms to the `FlowEvent` protocol. In practice that can mean defining a simple `enum`.

```swift
import Flowy
enum MyFlowEvent: FlowEvent {
    case detailRequired
    case detailDone
    case masterDone
}
```

You can create as many `enums` or `structs` as you wish as long they conform to the `FlowEvent` protocol.

#### transitionKey

`transitionKey: String?` is an optional property that specifies a concrete `Flow` to transition to when multiple `FlowEvents` trigger one `Flow`.

### Creating a FlowEventsSourceable

`FlowEventsSourceable` is a `protocol` responsible for delivering `FlowEvents` from your app to Flowy. To create one it's enough to do following.

```swift
import Flowy
import RxSwift
class MyFlowEventsSource: FlowEventsSourceable {
    let events = PublishSubject<FlowEvent>()
}
```

You should always use the same instance of `FlowEventsSourceable` that you passed to the `Flowy` instance. The best way to do it is via _Dependency Incjetion_, but this is out of scope of this document.

### Creating Flowy

`Flowy` is the bridge between your app and the Flowy coordination engine. To create one you need a root `Flow` that will begin the coordination and `FlowEventsSourceable` that will drive it.

```swift
import Flowy

let rootFlow = MyRootFlow()
let eventsSource = MyFlowEventsSource()

let flowy = Flowy(
  rootFlow: rootFlow,
  eventsSource: eventsSource
)
```

You must keep a strong reference to the `flowy` instance. The easiest way to do this is to store it in your `AppDelegate` as a instance property.

#### Registering Flows

To create the needed `Flow` instances during runtime and avoid overhead of creating all views on startup, Flowy uses factory closures to instantiate your `Flows`.

You can think of it as teaching Flowy it should create your `Flows` when the time comes to present them.

To register a `Flow`:

```swift
let flowy = Flowy(...)
flowy.registerFlow(DetailFlow.self) { root -> DetailFlow in
  DetailFlow(
    presentableParent: root,
    presentable: MyViewController()
  )
}
```

`root` is the `Presentable` of the `Flow` that coordinates to the `DetailFlow`. `Presentable` is an abstraction over things that can be presented, currently only `UIViewControllers`.

It is a good idea to use a _Dependency Injection_ along with Flowy to create your `UIViewControllers`.

```swift
let container = DependenciesContainer() // Container of registered dependencies, usually provided by a framework like Swinject.
let flowy = Flowy(...)
flowy.registerFlow(DetailFlow.self) { root -> DetailFlow in
  DetailFlow(
    presentableParent: root,
    presentable: container.resolve(MyViewController.self)
  )
}
```

### Starting the coordination

After instantiating `Flowy` and registering your `Flows` you just have to call the `start()` method.

```swift
let flowy = Flowy(...)
flowy.registerFlow(...)
flowy.registerFlow(...)

flowy.start()
```

## License

Flowy is available under the MIT license. See the LICENSE file for more info.

## Contact

Tomasz Bartkowski - [@tombartkowski](https://twitter.com/bartkowskitom) - tomaszbartkowski.studio@gmail.com

## Acknowledgements

- Icons made by [Freepik](https://www.freepik.com) from [www.flaticon.com](https://www.flaticon.com/)
