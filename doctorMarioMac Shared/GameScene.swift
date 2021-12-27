//
//  GameScene.swift
//  doctorMarioMac Shared
//
//  Created by Michael Levesque on 12/23/21.
//

import SpriteKit

class GameScene: SKScene {
    
    
    fileprivate var label : SKLabelNode?
    fileprivate var spinnyNode : SKShapeNode?
    fileprivate var gameboard : IGameboard?
    fileprivate var lastTimeInterval: TimeInterval = 0

    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    func setUpScene() {
        self.view?.ignoresSiblingOrder = true
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 4.0
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
            
            #if os(watchOS)
                // For watch we just periodically create one of these and let it spin
                // For other platforms we let user touch/mouse events create these
                spinnyNode.position = CGPoint(x: 0.0, y: 0.0)
                spinnyNode.strokeColor = SKColor.red
                self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 2.0),
                                                                   SKAction.run({
                                                                       let n = spinnyNode.copy() as! SKShapeNode
                                                                       self.addChild(n)
                                                                   })])))
            #endif
        }
        
        let width = 10
        let height = 15
        let cellSize: CGFloat = 32
        self.gameboard = createGameboard(gridWidth: width, gridHeight: height, cellWidth: cellSize, cellHeight: cellSize)
        self.gameboard?.position.x = -CGFloat(width) * cellSize / 2
        self.gameboard?.position.y = CGFloat(height) * cellSize / 2
        self.addChild(self.gameboard!)
        generateViruses(redCount: 30, yellowCount: 30, blueCount: 30, virusCeiling: 5)
    }
    
    func generateViruses(redCount: Int, yellowCount: Int, blueCount: Int, virusCeiling: Int) {
        let width = self.gameboard!.gridWidth
        let height = self.gameboard!.gridHeight
        let ceiling = virusCeiling >= height ? height - 1 : virusCeiling
        let virusPropResults = generateVirusPositions(
            gridWidth: width,
            gridHeight: height - ceiling,
            redCount: redCount,
            yellowCount: yellowCount,
            blueCount: blueCount)
        self.gameboard?.clear()
        for pos in virusPropResults.results {
            self.gameboard?.setVirus(x: pos.position.x, y: pos.position.y + ceiling, color: pos.color)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.gameboard?.Update(frameTime: CGFloat(currentTime - lastTimeInterval))
        lastTimeInterval = currentTime
    }
    
    #if os(watchOS)
    override func sceneDidLoad() {
        self.setUpScene()
    }
    #else
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    #endif

    func makeSpinny(at pos: CGPoint, color: SKColor) {
        if let spinny = self.spinnyNode?.copy() as! SKShapeNode? {
            spinny.position = pos
            spinny.strokeColor = color
            self.addChild(spinny)
        }
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.green)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.blue)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
   
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        //self.makeSpinny(at: event.location(in: self), color: SKColor.green)
        //_ = self.gameboard?.setVirus(x: 0, y: 0, color: .Red)
    }
    
    override func mouseDragged(with event: NSEvent) {
        //self.makeSpinny(at: event.location(in: self), color: SKColor.blue)
    }
    
    override func mouseUp(with event: NSEvent) {
        //self.makeSpinny(at: event.location(in: self), color: SKColor.red)
        generateViruses(redCount: 30, yellowCount: 30, blueCount: 30, virusCeiling: 5)
    }

}
#endif

