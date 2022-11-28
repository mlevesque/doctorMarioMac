//
//  GameStateMachine.swift
//  doctorMarioMac
//
//  Created by Michael Levesque on 1/8/22.
//

import GameplayKit

public class GameStateMachine : GKStateMachine {
    private var m_queue = Queue<AnyClass>()
    
    public func clearQueue() {
        m_queue.clear()
    }
    
    public func queueStates(_ stateClasses: [AnyClass]) {
        for c in stateClasses {
            m_queue.enqueue(c)
        }
    }
    
    public func clearAndQueueStates(stateClasses: [AnyClass]) {
        clearQueue()
        queueStates(stateClasses)
    }
    
    public func nextState() -> Bool {
        if let clazz = m_queue.dequeue() {
            return enter(clazz)
        }
        return false
    }
}
