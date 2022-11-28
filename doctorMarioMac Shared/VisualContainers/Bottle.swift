//
//  Bottle.swift
//  doctorMarioMac
//
//  Created by Michael Levesque on 12/26/21.
//

import SpriteKit

public func buildBottle(innerWidth: CGFloat, innerHeight: CGFloat, gameboard: SKNode) -> SKNode {
    let container = SKNode()
    let bottleHeadSize = CGSize(width: 6, height: 3)
    let bottleNeckSize = CGSize(width: 4, height: 2)
    let upperHeight = innerHeight / 2 - (bottleHeadSize.height + bottleNeckSize.height) / 2
    let lowerHeight = innerHeight / 2 + (bottleHeadSize.height + bottleNeckSize.height) / 2
    let halfWidth = innerWidth / 2
    let cgTileSize = CGSize(width: 1, height: 1)
    
    // add corners
    var sprite = SKSpriteNode(texture: getTexture("bottle_top_left"), size: cgTileSize)
    sprite.anchorPoint = CGPoint(x: 1, y: 0)
    sprite.position = CGPoint(x: -halfWidth, y: upperHeight)
    container.addChild(sprite)
    
    sprite = SKSpriteNode(texture: getTexture("bottle_top_right"), size: cgTileSize)
    sprite.anchorPoint = CGPoint(x: 0, y: 0)
    sprite.position = CGPoint(x: halfWidth, y: upperHeight)
    container.addChild(sprite)
    
    sprite = SKSpriteNode(texture: getTexture("bottle_bottom_left"), size: cgTileSize)
    sprite.anchorPoint = CGPoint(x: 1, y: 1)
    sprite.position = CGPoint(x: -halfWidth, y: CGFloat(-lowerHeight))
    container.addChild(sprite)
    
    sprite = SKSpriteNode(texture: getTexture("bottle_bottom_right"), size: cgTileSize)
    sprite.anchorPoint = CGPoint(x: 0, y: 1)
    sprite.position = CGPoint(x: halfWidth, y: CGFloat(-lowerHeight))
    container.addChild(sprite)
    
    // add top bottle
    sprite = SKSpriteNode(texture: getTexture("bottle_neck"), size: bottleNeckSize)
    sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
    sprite.position = CGPoint(x: 0, y: upperHeight)
    container.addChild(sprite)
    
    sprite = SKSpriteNode(texture: getTexture("bottle_head"), size: bottleHeadSize)
    sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
    sprite.position = CGPoint(x: 0, y: upperHeight + bottleNeckSize.height)
    container.addChild(sprite)
     
    // add connectors
    sprite = SKSpriteNode(texture: getTexture("bottle_left"), size: CGSize(width: 1, height: innerHeight))
    sprite.anchorPoint = CGPoint(x: 1, y: 1)
    sprite.position = CGPoint(x: -halfWidth, y: upperHeight)
    container.addChild(sprite)
    
    sprite = SKSpriteNode(texture: getTexture("bottle_right"), size: CGSize(width: 1, height: innerHeight))
    sprite.anchorPoint = CGPoint(x: 0, y: 1)
    sprite.position = CGPoint(x: halfWidth, y: upperHeight)
    container.addChild(sprite)
    
    sprite = SKSpriteNode(texture: getTexture("bottle_bottom"), size: CGSize(width: innerWidth, height: 1))
    sprite.anchorPoint = CGPoint(x: 0.5, y: 1)
    sprite.position = CGPoint(x: 0, y: -lowerHeight)
    container.addChild(sprite)
    
    let topWidth = (innerWidth - bottleNeckSize.width) / 2
    sprite = SKSpriteNode(texture: getTexture("bottle_top"), size: CGSize(width: topWidth , height: 1))
    sprite.anchorPoint = CGPoint(x: 1, y: 0)
    sprite.position = CGPoint(x: -bottleNeckSize.width / 2, y: upperHeight)
    container.addChild(sprite)
    
    sprite = SKSpriteNode(texture: getTexture("bottle_top"), size: CGSize(width: topWidth , height: 1))
    sprite.anchorPoint = CGPoint(x: 0, y: 0)
    sprite.position = CGPoint(x: bottleNeckSize.width / 2, y: upperHeight)
    container.addChild(sprite)
    
    // interior
    for y:Int in -Int(lowerHeight)...Int(upperHeight) {
        for x:Int in -Int(halfWidth)..<Int(halfWidth) {
            sprite = SKSpriteNode(texture: getTexture("bottle_inside"), size: cgTileSize)
            sprite.anchorPoint = CGPoint(x: 0, y: 0.5)
            sprite.position = CGPoint(x: x, y: y)
            container.addChild(sprite)
        }
    }
    
    // place gameboard
    gameboard.position = CGPoint(x: -innerWidth / 2, y: upperHeight)
    container.addChild(gameboard)
    
    return container
}
