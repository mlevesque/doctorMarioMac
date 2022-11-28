//
//  BaseScene.swift
//  doctorMarioMac
//
//  Created by Michael Levesque on 11/25/22.
//

import SpriteKit

class BaseScene : SKScene {
    fileprivate var m_lastTimeInterval: TimeInterval = 0
    fileprivate let m_parent = SKNode()
    
    public func onSetUpScene() {
        // override
    }
    
    public func onUpdate(_ delta: TimeInterval) {
        // override
    }
    
    public override func addChild(_ node: SKNode) {
        self.m_parent.addChild(node)
    }
    
    fileprivate func setUpScene() {
        self.view?.ignoresSiblingOrder = true
        self.scaleMode = .aspectFit
        self.scene?.backgroundColor = .black
        self.m_parent.setScale(16.0)
        super.addChild(self.m_parent)
        onSetUpScene()
    }
    
    override final func update(_ currentTime: TimeInterval) {
        onUpdate(currentTime - m_lastTimeInterval)
        m_lastTimeInterval = currentTime
    }
    
    #if os(watchOS)
    override final func sceneDidLoad() {
        self.setUpScene()
    }
    #else
    override final func didMove(to view: SKView) {
        self.setUpScene()
    }
    #endif
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension BaseScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}
#endif

#if os(OSX)
// Mouse-based event handling
extension BaseScene {

    override func mouseDown(with event: NSEvent) {
    }
    
    override func mouseDragged(with event: NSEvent) {
    }
    
    override func mouseUp(with event: NSEvent) {
    }
}
#endif
