//
//  APIService.swift
//  DontBeBored
//
//  Created by reztsov on 7/23/19.
//  Copyright © 2019 reztsov. All rights reserved.
//

import Foundation
import Combine
import os

struct APIService {
    let baseURL = URL(string: "http://www.boredapi.com/api")!
    static let shared = APIService()
    let decoder = JSONDecoder()
    let log = OSLog(subsystem: "com.nixsolutions.dontBeBored.APIService", category: "API")

    enum APIError: Error {
        case noResponse
        case jsonDecodingError(error: Error)
        case networkError(error: Error)
    }

    enum Endpoint {
        case randomEvent
        case findByKey(_ key: String)
        case findByType(_ type: Filter)
        case findByParticipants(_ participants: String)
        case findByPrice(_ price: String)
        case findByPriceRange(min: String, max: String)
        case findByAccessibility(_ value: String)
        case findByAccessibilityRange(min: String, max: String)

        var path: String {
            return "activity"
        }

        var params: [String: String]? {
            switch self {
            case .randomEvent: return nil
            case .findByKey(let key): return ["key": key]
            case .findByType(let type): return [type.rawValue: type.value]
            case .findByPrice(let price): return ["price": price]
            case .findByParticipants(let value): return ["participants": value]
            case .findByPriceRange(let min, let max): return ["minprice": min, "maxprice": max]
            case .findByAccessibility(let value): return ["accessibility": value]
            case .findByAccessibilityRange(let min, let max): return ["minaccessibility": min, "maxaccessibility": max]
            }
        }
    }

    func GET(endpoint: Endpoint) -> AnyPublisher<Result<Activity, APIError>, Never> {
        let id = OSSignpostID(log: log)
        os_signpost(.begin,
                    log: log,
                    name: "GET",
                    signpostID: id,
                    "Endpoint: %s", endpoint.path)

        guard let request = makeRequest(endpoint: endpoint) else { return Empty().eraseToAnyPublisher() }

        return URLSession.shared
            .dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: Activity.self, decoder: decoder)
            .map { Result.success($0) }
            .catch { error in Just(Result.failure(.jsonDecodingError(error: error)));}
            .handleEvents(receiveCompletion: { _ in
                os_signpost(.end,
                log: self.log,
                name: "GET",
                signpostID: id,
                "Endpoint: %s", endpoint.path)
            }, receiveCancel: {
                os_signpost(.end,
                log: self.log,
                name: "GET",
                signpostID: id,
                "Endpoint: %s", endpoint.path)
            })
            .eraseToAnyPublisher()

    }

    func makeRequest(endpoint: Endpoint) -> URLRequest? {
        let queryURL = baseURL.appendingPathComponent(endpoint.path)
        var components = URLComponents(url: queryURL, resolvingAgainstBaseURL: true)!
        components.queryItems = []

        if let params = endpoint.params {
            for (_, value) in params.enumerated() {
                components.queryItems?.append(URLQueryItem(name: value.key, value: value.value))
            }
        }

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        return request
    }
}
