//
//  ActivitiesService.swift
//  DontBeBored
//
//  Created by reztsov on 7/23/19.
//  Copyright © 2019 reztsov. All rights reserved.
//

import SwiftUI
import Combine
import os

final class ActivitiesService: ObservableObject {
    @Published
    var activity: Activity? = nil
    let log = OSLog(subsystem: "com.nixsolutions.dontBeBored.Activities", category: "FetchCategory")

    @Published
    var isLoading: Bool = true

    private var cancellable: Cancellable?

    func fetchActivity(endpoint: APIService.Endpoint) {
        let id = OSSignpostID(log: log)
        os_signpost(.begin,
                    log: log,
                    name: "Fetch",
                    signpostID: id)
        isLoading = true
        cancellable = APIService.shared.GET(endpoint: endpoint)
            .receive(on: RunLoop.main)
            .handleEvents(receiveCompletion: { _ in
                os_signpost(.end, log: self.log, name: "Fetch", signpostID: id)
                self.isLoading = false
            }, receiveCancel: {
                os_signpost(.end, log: self.log, name: "Fetch", signpostID: id)
                self.isLoading = false
            })
            .tryMap { try $0.get() }
            .catch { _ in Just(self.activity) }
            .assign(to: \.activity, on: self)

    }

    deinit {
        cancellable?.cancel()
    }
}
