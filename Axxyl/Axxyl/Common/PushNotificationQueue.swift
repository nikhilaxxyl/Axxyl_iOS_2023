//
//  PushNotificationQueue.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 29/11/22.
//

import Foundation

struct PushNotificationQueue<T>: CustomStringConvertible {
    
    private var elements: [T] = []
    public init() {}
    
    var isEmpty: Bool {
        elements.isEmpty
    }
    
    var peek: T? {
        elements.first
    }
    
    var description: String {
        if isEmpty { return "Queue is empty..." }
        return "---- Queue start ----\n"
            + elements.map({"\($0)"}).joined(separator: " -> ")
            + "\n---- Queue End ----"
    }
    
    mutating func enqueue(_ value: T) {
        elements.append(value)
    }
    
    mutating func dequeue() -> T? {
        isEmpty ? nil : elements.removeFirst()
    }
}
