//
//  ActorViewController.swift
//  ActorViewController
//
//  Created by Kah Seng Lee on 30/08/2021.
//

import UIKit

// MARK: Counter Actor
@MainActor
struct Test {
    
}

@MainActor
class TestClass {
    
}

actor Counter {
    let name: String
    
    private(set) var count = 0
    
    init(name: String) {
        self.name = name
    }
    
    nonisolated func getName() -> String {
        return name
    }
    
    func addCount() {
        count += 1
    }
}

class ActorViewController: UIViewController {
    
    // MARK: Implementation
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @MainActor
    @IBAction func startButtonTapped(_ sender: Any) {
        
        let totalCount = 1000
        let counter = Counter(name: "eee")
        print(counter.getName())
        
        // Create a parent task
        Task {
            
            // Create a task group
            await withTaskGroup(of: Void.self, body: { taskGroup in
                
                for _ in 0..<totalCount {
                    // Create child task
                    taskGroup.addTask {
                        await counter.addCount()
                    }
                }
            })
            
            statusLabel.text = "\(await counter.count)"
        }
   
//        testTaskGroup()
//        testAsyncLetBinding()
    }
    
    func request() {
        Task {
            await testAsync()
            
            do {
                let testStr = try await testAsyncAndThrows()
                print(testStr as Any)
            } catch {
                
            }
        }
    }
    
    func testAsync() async {
        try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
    }
    
    func testAsyncAndThrows() async throws -> String {
        return "test"
    }

    func testAsyncLetBinding() {
        Task {
            async let a = performTaskA()
            async let b = performTaskB()
            let sum = await(a + b)
            print(sum)
        }
    }
    
    func testTaskGroup() {
        print("Group start")
        Task {
            let result = await withTaskGroup(of: Int.self, returning: Int.self, body: {
                taskGroup in
                @Sendable func performTaskA() async -> Int {
                    try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                    print("A complete")
                    return 2
                }

                @Sendable func performTaskB() async -> Int {
                    try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                    print("B complete")
                    return 3
                }

                for index in 0...1 {
                    taskGroup.addTask {
                        if index == 0 {
                            let value = await performTaskA()
                            return value
                        } else {
                            let value = await performTaskB()
                            return value
                        }
                    }
                }

                var sum = 0
                for await result in taskGroup {
                    sum += result
                }

                return sum
            })

            print("Group end - \(result)")
        }
        
        Task {
            await withTaskGroup(of: Int.self, body: {
                taskGroup in
                @Sendable func performTaskA() async -> Int {
                    try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                    print("A complete")
                    return 2
                }
                
                @Sendable func performTaskB() async -> Int {
                    try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                    print("B complete")
                    return 3
                }
                
                for index in 0...1 {
                    taskGroup.addTask {
                        if index == 0 {
                            let value = await performTaskA()
                            return value
                        } else {
                            let value = await performTaskB()
                            return value
                        }
                    }
                }
                
                var sum = 0
                for await result in taskGroup {
                    sum += result
                }
                
                print("Group end - \(sum)")
            })
        }
    }
    
    @Sendable func performTaskA() async -> Int {
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        print("A complete")
        return 2
    }
    
    @Sendable func performTaskB() async -> Int {
        try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
        print("B complete")
        return 3
    }
}
