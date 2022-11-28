//
//  Queue.swift
//  doctorMarioMac
//
//  Created by Michael Levesque on 1/8/22.
//

public class Queue<T> {
    private class Node<T> {
        public let value: T
        public var next: Node<T>? = nil
        public init(_ val: T) {value = val}
    }
    
    private var m_head: Node<T>!
    private var m_tail: Node<T>!
    
    init() {
        m_head = nil
        m_tail = nil
    }
    
    public func enqueue(_ value: T) {
        let node = Node<T>(value)
        guard m_tail != nil else {
            m_head = node
            m_tail = node
            return
        }
        
        m_tail?.next = node
        m_tail = node
    }
    
    public func dequeue() -> T? {
        let node = m_head
        m_head = m_head?.next
        if m_head == nil {
            m_tail = nil
        }
        return node?.value
    }
    
    public func clear() {
        m_head = nil
        m_tail = nil
    }
    
    public func isEmpty() -> Bool {
        return m_head == nil
    }
    
    public func peek() -> T? {
        return m_head?.value
    }
}
