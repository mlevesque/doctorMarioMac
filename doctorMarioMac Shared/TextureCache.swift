//
//  TextureCache.swift
//  doctorMarioMac
//
//  Created by Michael Levesque on 12/25/21.
//

import SpriteKit

fileprivate var g_atlus: SKTextureAtlas = SKTextureAtlas.init(named: "SpriteSheet")
fileprivate var g_textures: Dictionary<String, SKTexture> = Dictionary()

public func getTexture(_ name: String) -> SKTexture {
    if let tex = g_textures[name] {
        return tex
    }
    let tex = g_atlus.textureNamed(name)
    tex.filteringMode = .nearest
    g_textures[name] = tex
    return tex
}

public func getSinglePillTexture(color: Color) -> SKTexture {
    return getTexture("pill_\(color.description)_s")
}

public func getDoublePillTexture(color: Color, vertical: Bool, firstPart: Bool) -> SKTexture {
    return getTexture("pill_\(color.description)_\(vertical ? "v" : "h")\(firstPart ? "1" : "2")")
}
