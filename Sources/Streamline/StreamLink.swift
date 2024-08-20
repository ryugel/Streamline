//
//  File.swift
//  
//
//  Created by ryugel on 17/08/2024.
//  Copyright © 2024 DeRosa. All rights reserved.
//
       

import Foundation
import Combine

/// A structure that links a data stream to a pipeline for processing.
///
/// The `StreamLink` struct is responsible for fetching data from a given URL using a provided service
/// and then passing the data through a `StreamChain` for processing, error handling, and storage.
public struct StreamLink<Content: Any> {

    /// The service responsible for fetching the data as a publisher.
    public let service: AnyPublisher<Content, Error>

    /// The pipeline (`StreamChain`) through which the data will be processed.
    public let streamChain: StreamChain<Content>

    /// Initializes a new `StreamLink` instance with the given URL, service, and stream chain.
    ///
    /// - Parameters:
    ///   - service: The publisher service that provides the data.
    ///   - streamChain: The pipeline for processing the fetched data.
    public init(service: AnyPublisher<Content, Error>, streamChain: StreamChain<Content>) {
        self.service = service
        self.streamChain = streamChain
        applyStreamChain()
    }

    /// Applies the stream chain to the service, handling data reception, errors, and completion.
    ///
    /// This method sets up the data stream to be processed by the `StreamChain`, ensuring
    /// that all the appropriate closures are called for error handling, data storage, and completion.
    private func applyStreamChain() {
        var cancellables = streamChain.cancellables
        service
            .receive(on: streamChain.receiveQueue)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    streamChain.onFailure?(error)
                case .finished:
                    streamChain.onFinish?()
                }
            }, receiveValue: { value in
                streamChain.onReceive?(value)
                streamChain.onStore?(value, &cancellables)
            })
            .store(in: &cancellables)
        
        _ = streamChain.withUpdatedCancellables(cancellables)
    }
}
