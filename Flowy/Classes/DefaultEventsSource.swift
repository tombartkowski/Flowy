//
//  DefaultEventsSource.swift

//
//  Created by Tomasz Bartkowski on 24/04/2021.
//  Copyright © 2021 Tomasz Bartkowski. All rights reserved.
//

import RxSwift

public class DefaultEventsSource: FlowEventsSourceable {
    public let events = PublishSubject<FlowEvent>()
    
    public static let shared = DefaultEventsSource()
}
