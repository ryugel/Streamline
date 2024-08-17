//
//  File.swift
//  
//
//  Created by ryugel on 17/08/2024.
//  Copyright © 2024 DeRosa. All rights reserved.
//
       

import Foundation
import Combine

/// A generic pipeline that processes a sequence of operations on a stream of data.
///
/// The `StreamChain` struct allows you to define and manage a pipeline for handling data streams,
/// with options to handle errors, completion, data reception, and data storage.
public struct StreamChain<Content: Any> {

    /// Closure to handle any errors that occur during the stream processing.
    public var onFailure: ((Error) -> Void)?

    /// Closure to be called when the stream processing finishes successfully.
    public var onFinish: (() -> Void)?

    /// Closure that receives the data once it has been fetched from the stream.
    public var onReceive: (([Content]) -> Void)?

    /// Closure to store the received data and manage the cancellation of the stream.
    public var onStore: (([Content], inout Set<AnyCancellable>) -> Void)?

    /// The dispatch queue on which the data will be received and processed. Defaults to `.main`.
    public var receiveQueue: DispatchQueue = .main

    /// A set of `AnyCancellable` instances to keep track of the stream subscriptions.
    public var cancellables = Set<AnyCancellable>()

    /// Initializes a new `StreamChain` instance with the provided closures and queue.
    ///
    /// - Parameters:
    ///   - onFailure: Closure to handle errors.
    ///   - onFinish: Closure to be called upon successful completion.
    ///   - onReceive: Closure that receives the fetched data.
    ///   - onStore: Closure to store the received data and manage cancellations.
    ///   - receiveQueue: The dispatch queue for data reception and processing.
    public init(
        onFailure: ((Error) -> Void)? = nil,
        onFinish: (() -> Void)? = nil,
        onReceive: (([Content]) -> Void)? = nil,
        onStore: (([Content], inout Set<AnyCancellable>) -> Void)? = nil,
        receiveQueue: DispatchQueue = .main
    ) {
        self.onFailure = onFailure
        self.onFinish = onFinish
        self.onReceive = onReceive
        self.onStore = onStore
        self.receiveQueue = receiveQueue
    }

    /// Updates the pipeline with a new set of cancellables.
    ///
    /// - Parameter cancellables: The new set of `AnyCancellable` instances.
    /// - Returns: A new `StreamChain` instance with updated cancellables.
    public func withUpdatedCancellables(_ cancellables: Set<AnyCancellable>) -> StreamChain {
        var newStreamChain = self
        newStreamChain.cancellables = cancellables
        return newStreamChain
    }
}
