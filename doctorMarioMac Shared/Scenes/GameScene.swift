//
//  GameScene.swift
//  doctorMarioMac Shared
//
//  Created by Michael Levesque on 12/23/21.
//

import SpriteKit

class GameScene : BaseScene {
    fileprivate var m_model = GameModel()
    fileprivate var m_stateMachine: GameStateMachine! = nil
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        return scene
    }
    
    override public func onSetUpScene() {
        // BACKGROUND
        let back = buildTileBackground(color1: getColorSet("LowTile"), color2: OSColor.black, screenWidth: 50, screenHeight: 38)
        addChild(back)
        
        // GAMEBOARD
        let width = 10
        let height = 20
        m_model.gameboard = createGameboard(gridWidth: width, gridHeight: height)
        m_model.gameboard?.position.x = -CGFloat(width) / 2
        m_model.gameboard?.position.y = CGFloat(height) / 2
        
        // BOTTLE
        let bottle = buildBottle(innerWidth: CGFloat(width), innerHeight: CGFloat(height), gameboard: m_model.gameboard!)
        self.addChild(bottle)
        
        // PILL
        let pillPos = IntPoint(x: m_model.gameboard!.gridWidth / 2 - 1, y: 0)
        let pill = createRandomizedGameboardPill(position: pillPos, vertical: false)
        m_model.gameboard?.addChild(pill)
        pill.pillPosition = pillPos
        
        // STATE MACHINE
        let states = [
            StatePopulateViruses(model: m_model)
        ]
        m_stateMachine = GameStateMachine(states: states)
        m_stateMachine.enter(StatePopulateViruses.self)
    }
    
    override public func onUpdate(_ delta: TimeInterval) {
        m_stateMachine.update(deltaTime: delta)
        m_model.gameboard?.update(delta)
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

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
extension GameScene {

    override func mouseDown(with event: NSEvent) {
    }
    
    override func mouseDragged(with event: NSEvent) {
    }
    
    override func mouseUp(with event: NSEvent) {
        m_stateMachine.enter(StatePopulateViruses.self)
    }
}
#endif
