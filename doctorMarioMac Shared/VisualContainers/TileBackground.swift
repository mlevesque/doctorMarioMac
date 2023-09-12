//
//  TileBackground.swift
//  doctorMarioMac
//
//  Created by Michael Levesque on 11/26/22.
//

import SpriteKit

func buildTileBackground(color1: OSColor, color2: OSColor, screenWidth: Int, screenHeight: Int) -> SKNode {
    let container = SKNode()
    var c1 = color1
    var c2 = color2
    for y in (-screenHeight/2)..<(screenHeight/2) {
        for x in stride(from: -screenWidth / 2, to: screenWidth / 2, by: 2) {
            var tile = SKSpriteNode(color: c1, size: CGSize(width: 1, height: 1))
            tile.anchorPoint = CGPoint(x: 0, y: 0.5)
            tile.position = CGPoint(x: x, y: y)
            container.addChild(tile)
            tile = SKSpriteNode(color: c2, size: CGSize(width: 1, height: 1))
            tile.anchorPoint = CGPoint(x: 0, y: 0.5)
            tile.position = CGPoint(x: x + 1, y: y)
            container.addChild(tile)
        }
        let temp = c1
        c1 = c2
        c2 = temp
    }
    return container
}
