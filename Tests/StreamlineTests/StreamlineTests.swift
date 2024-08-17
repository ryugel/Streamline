import XCTest
import Combine
@testable import Streamline

final class StreamlineTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    func testStreamChainReceivesData() {
        // Given
        let expectation = XCTestExpectation(description: "StreamChain receives data")
        var receivedData: [Int] = []
        
        let streamChain = StreamChain<Int>(
            onFailure: { _ in },
            onFinish: { },
            onReceive: { data in
                receivedData = data
                expectation.fulfill()
            }, receiveQueue: .main
            
            
        )
        
        let publisher = Just([1, 2, 3])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // When
        _ = StreamLink(
            url: URL(string: "https://ryugel.ryugel")!,
            service: publisher,
            streamChain: streamChain
        )
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedData, [1, 2, 3], "StreamChain should receive data from the publisher")
    }
    
    func testStreamChainHandlesError() {
        // Given
        let expectation = XCTestExpectation(description: "StreamChain handles error")
        var receivedError: Error?
        
        enum TestError: Error {
            case test
        }
        
        let streamChain = StreamChain<Int>(
            onFailure: { error in
                receivedError = error
                expectation.fulfill()
            },
            onFinish: { },
            onReceive: { _ in }
        )
        
        let publisher = Fail<[Int], Error>(error: TestError.test)
            .eraseToAnyPublisher()
        
        // When
        _ = StreamLink(
            url: URL(string: "https://baran.baran")!,
            service: publisher,
            streamChain: streamChain
        )
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedError, "StreamChain should handle errors from the publisher")
    }
    
    func testStreamChainCompletion() {
        // Given
        let expectation = XCTestExpectation(description: "StreamChain calls onFinish")
        var didFinish = false
        
        let streamChain = StreamChain<Int>(
            onFailure: { _ in },
            onFinish: {
                didFinish = true
                expectation.fulfill()
            },
            onReceive: { _ in }
            
        )
        
        let publisher = Just([1, 2, 3])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // When
        _ = StreamLink(
            url: URL(string: "https://ixaal.ixaal")!,
            service: publisher,
            streamChain: streamChain
        )
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(didFinish, "StreamChain should call onFinish when the stream completes")
    }
}
