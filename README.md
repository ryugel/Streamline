# Streamline

**Streamline** is a sophisticated Swift package designed to manage data streams in your applications with elegance and flexibility. By leveraging generics, separation of concerns, and the power of Combine, Streamline provides exceptional flexibility and reusability, ensuring robust error handling and a scalable, maintainable architecture.

## Overview

Streamline consists of two primary components: **StreamChain** and **StreamLink**.

- **StreamChain** is a generic pipeline that processes a sequence of operations on a data stream. It allows you to handle errors, manage completion, receive data, and store results effectively.
  
- **StreamLink** serves as the bridge between your data source and the processing pipeline, fetching data from a specified URL and passing it through the `StreamChain` for processing.

These components work together to provide a streamlined approach to managing data streams in Swift, making it ideal for developers looking to build scalable, reactive applications with a strong architectural foundation.

## Features

- **Flexible Pipeline:** Easily configure data processing with support for custom error handling, data reception, and storage.
- **Combine Integration:** Seamlessly integrate with Combine to handle asynchronous streams of data.
- **Generics Support:** Utilize generic types to ensure your pipeline is flexible and reusable across different data models.
- **Robust Error Handling:** Effectively handle errors at any stage of the data stream processing.
- **Scalable Architecture:** Build applications that are easy to scale and maintain with a clear separation of concerns.

## Installation

### Swift Package Manager

Add the Streamline package to your project using Swift Package Manager:

1. In Xcode, select **File > Add Packages**.
2. Enter the repository URL: `https://github.com/ryugel/Streamline`.
3. Choose the version or branch you want to use.
4. Add the package to your project.

Alternatively, add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/ryugel/Streamline", from: "1.0.0")
]
```

## Usage

### StreamChain

`StreamChain` is the core pipeline structure where you define how your data should be processed.

```swift
import Streamline
import Combine

// Define a StreamChain for processing data
var pipeline = StreamChain<Post>()

// Closure to handle received data
pipeline.onReceive = { posts in
    // Process received data, e.g., update your UI or store data
    print("Received posts: \(posts)")
}

// Closure to handle errors
pipeline.onFailure = { error in
    print("Error occurred: \(error.localizedDescription)")
}

// Closure to be called when the stream finishes
pipeline.onFinish = {
    print("Stream finished")
}

// Closure to store data and manage cancellables
pipeline.onStore = { posts, cancellables in
    // Optionally store data or manage cancellables if needed
}

// Set the queue on which data will be received and processed
pipeline.receiveQueue = .main
```

### StreamLink

`StreamLink` connects a data source (like a network service) to the `StreamChain`, fetching data and passing it through the pipeline.

```swift
import Streamline
import Combine

// Define a URL and service that returns a publisher
let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
let service: AnyPublisher<[Post], Error> = URLSession.shared.dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: [Post].self, decoder: JSONDecoder())
    .eraseToAnyPublisher()

// Create a StreamLink to fetch and process data
let streamLink = StreamLink(url: url, service: service, streamChain: pipeline)

// Ensure the StreamLink is retained to keep the subscription active
```

### Example

Here’s a complete example demonstrating how to set up a `StreamChain` and `StreamLink` to fetch and process data:

```swift
import SwiftUI
import Streamline
import Combine

// Define the Post model
struct Post: Identifiable, Decodable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

// SwiftUI view to display posts
struct PostListView: View {
    @StateObject private var viewModel = PostListViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.posts) { post in
                VStack(alignment: .leading) {
                    Text(post.title)
                        .font(.headline)
                    Text(post.body)
                        .font(.subheadline)
                        .lineLimit(3)
                }
                .padding()
            }
            .navigationTitle("Posts")
            .onAppear {
                viewModel.fetchPosts()
            }
        }
    }
}

// ViewModel to manage fetching and processing posts
class PostListViewModel: ObservableObject {
    @Published var posts: [Post] = []
    private var cancellables = Set<AnyCancellable>()
    
    func fetchPosts() {
        // Define a StreamChain for processing data
        var pipeline = StreamChain<Post>()
        
        // Handle received data
        pipeline.onReceive = { [weak self] posts in
            self?.posts = posts
        }
        
        // Handle errors
        pipeline.onFailure = { error in
            print("Error occurred: \(error.localizedDescription)")
        }
        
        // Handle stream completion
        pipeline.onFinish = {
            print("Stream finished")
        }
        
        // Store data and manage cancellables if needed
        pipeline.onStore = { posts, cancellables in
            // Optionally store data or manage cancellables
        }
        
        // Set the queue on which data will be processed
        pipeline.receiveQueue = .main
        
        // Define a URL and service
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        let service: AnyPublisher<[Post], Error> = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Post].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
        
        // Create a StreamLink to fetch and process data
        _ = StreamLink(url: url, service: service, streamChain: pipeline)
    }
}
```

## Contributing

Contributions are welcome! If you’d like to contribute to Streamline, please open an issue or submit a pull request.

## License

Streamline is released under the MIT license. See [LICENSE](./LICENSE) for details.
