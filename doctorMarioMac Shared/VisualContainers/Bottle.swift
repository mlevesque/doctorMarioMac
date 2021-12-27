//
//  Bottle.swift
//  doctorMarioMac
//
//  Created by Michael Levesque on 12/26/21.
//

import SpriteKit

public func buildBottle(innerWidth: CGFloat, innerHeight: CGFloat, tileSize: CGFloat, gameboard: SKNode) -> SKNode {
    let container = SKNode()
    let bottleHeadSize = CGSize(width: 6 * tileSize, height: 3 * tileSize)
    let bottleNeckSize = CGSize(width: 4 * tileSize, height: 2 * tileSize)
    let upperHeight = innerHeight / 2 - (bottleHeadSize.height + bottleNeckSize.height) / 2
    let lowerHeight = innerHeight / 2 + (bottleHeadSize.height + bottleNeckSize.height) / 2
    let halfWidth = innerWidth / 2
    let cgTileSize = CGSize(width: tileSize, height: tileSize)
    
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
    sprite.position = CGPoint(x: -halfWidth, y: -lowerHeight)
    container.addChild(sprite)
    
    sprite = SKSpriteNode(texture: getTexture("bottle_bottom_right"), size: cgTileSize)
    sprite.anchorPoint = CGPoint(x: 0, y: 1)
    sprite.position = CGPoint(x: halfWidth, y: -lowerHeight)
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
    sprite = SKSpriteNode(texture: getTexture("bottle_left"), size: CGSize(width: tileSize, height: innerHeight))
    sprite.anchorPoint = CGPoint(x: 1, y: 1)
    sprite.position = CGPoint(x: -halfWidth, y: upperHeight)
    container.addChild(sprite)
    
    sprite = SKSpriteNode(texture: getTexture("bottle_right"), size: CGSize(width: tileSize, height: innerHeight))
    sprite.anchorPoint = CGPoint(x: 0, y: 1)
    sprite.position = CGPoint(x: halfWidth, y: upperHeight)
    container.addChild(sprite)
    
    sprite = SKSpriteNode(texture: getTexture("bottle_bottom"), size: CGSize(width: innerWidth, height: tileSize))
    sprite.anchorPoint = CGPoint(x: 0.5, y: 1)
    sprite.position = CGPoint(x: 0, y: -lowerHeight)
    container.addChild(sprite)
    
    let topWidth = (innerWidth - bottleNeckSize.width) / 2
    sprite = SKSpriteNode(texture: getTexture("bottle_top"), size: CGSize(width: topWidth , height: tileSize))
    sprite.anchorPoint = CGPoint(x: 1, y: 0)
    sprite.position = CGPoint(x: -bottleNeckSize.width / 2, y: upperHeight)
    container.addChild(sprite)
    
    sprite = SKSpriteNode(texture: getTexture("bottle_top"), size: CGSize(width: topWidth , height: tileSize))
    sprite.anchorPoint = CGPoint(x: 0, y: 0)
    sprite.position = CGPoint(x: bottleNeckSize.width / 2, y: upperHeight)
    container.addChild(sprite)
    
    // place gameboard
    gameboard.position = CGPoint(x: -innerWidth / 2, y: upperHeight)
    container.addChild(gameboard)
    
    return container
}
