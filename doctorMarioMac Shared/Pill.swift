//
//  Pill.swift
//  doctorMarioMac
//
//  Created by Michael Levesque on 12/23/21.
//

import SpriteKit

public typealias ColorPair = (Color, Color)

// MARK: INTERFACE

/// A pill object that floats over the gameboard.
public protocol IGameboardPill : IPill {
    /// Pill cell position.
    var pillPosition: IntPoint {get set}
    /// Cell position offsets of each part of the pill relative to the pill cell position.
    /// This can be an array of 1 or 2, depending if it is a 2 part pill, or a 1 part pill.
    var pillPartPositions: [IntPoint] {get}
    /// Flag used to apply a small downward offset on a user controlled floating pill where
    /// a collision is detected below the pill.
    var settling: Bool {get set}
}

/// A Pill object
public protocol IPill : SKNode {
    /// Flag indicating if the pill is in vertical orientation or not
    var isVertical: Bool {get}
    /// The colors of each part of the pill. The first entry will be the first half (top-left most).
    /// The second entry will be the second half.
    var colors: ColorPair {get}
    /// Flag indicating if the pill is a single part pill (true), or a two part pill (false).
    var isSingle: Bool {get}
    
    /// Rotates the pill 90 degrees clockwise.
    /// - Returns: Void
    func rotateClockwise() -> Void
    
    /// Rotates the pill 90 degrees counter-clockwise.
    /// - Returns: Void
    func rotateCounterClockwise() -> Void
}

// MARK: FACTORY METHODS

/// Generates a gameboard pill with random color.
/// - Parameters:
///   - position: initial cell position for pill
///   - vertical: if the pill should initialize as vertical or not
/// - Returns: newly created Gameboard Pill
public func createRandomizedGameboardPill(position: IntPoint, vertical: Bool) -> IGameboardPill {
    return createGameboardPill(position: position, color1: pickRandomColor(), color2: pickRandomColor(), vertical: vertical)
}

/// Generates a gameboard pill with the given parameters.
/// - Parameters:
///   - position: initial cell position for pill
///   - color1: initial color of first part of pill
///   - color2: initial color of second part of pill
///   - vertical: if the pill should initialize as vertical or not
/// - Returns: newly created Gameboard Pill
public func createGameboardPill(position: IntPoint, color1: Color, color2: Color, vertical: Bool) -> IGameboardPill {
    return GameboardPill(position: position, color1: color1, color2: color2, vertical: vertical)!
}


// MARK: PRIVATE IMPLEMENTATIONS

fileprivate func getSharedDecoding(_ decoder: NSCoder) -> (c1: Color, c2: Color, v: Bool) {
    return (
        c1: convertStringToColor(decoder.decodeObject(forKey: "color1") as? String ?? ""),
        c2: convertStringToColor(decoder.decodeObject(forKey: "color2") as? String ?? ""),
        v: decoder.decodeBool(forKey: "vertical")
    )
}


// MARK : GAMEBOARD PILL

fileprivate class GameboardPill : BasePill, IGameboardPill {
    private var m_position: IntPoint
    
    init?(position: IntPoint, color1: Color, color2: Color, vertical: Bool) {
        m_position = (x: position.x, y: position.y)
        super.init(color1, color2, vertical, .regular(0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        m_position = IntPoint(x: aDecoder.decodeInteger(forKey: "positionX"), y: aDecoder.decodeInteger(forKey: "positionY"))
        let params = getSharedDecoding(aDecoder)
        super.init(params.c1, params.c2, params.v, .coder(aDecoder))
    }
    
    // MARK: Getters / Setters
    
    public var pillPartPositions: [IntPoint] {
        get {
            let secondPos = m_vertical ? IntPoint(x: m_position.x, m_position.y + 1) : IntPoint(x: m_position.x + 1, y: m_position.y)
            return [(x: m_position.x, y: m_position.y), secondPos]
        }
    }
    public var settling: Bool {
        get {return m_settling}
        set {
            m_settling = newValue
            updateNodePosition()
        }
    }
    public var pillPosition: IntPoint {
        get {return m_position}
        set {
            m_position = IntPoint(x: newValue.x, y: newValue.y)
            updateNodePosition()
        }
    }
    
    // MARK: Internal Updates
    
    fileprivate override func updateNodePosition() -> Void {
        let settle = m_settling ? (1.0 / 8.0) : 0.0
        m_nodes[0].position = CGPoint(
            x: CGFloat(m_position.x),
            y: -CGFloat(m_position.y) - settle)
        
        m_nodes[1].position.x = CGFloat(m_position.x)
        m_nodes[1].position.x += m_vertical ? 0 : 1
        m_nodes[1].position.y = -CGFloat(m_position.y) * 1 - settle
        m_nodes[1].position.y -= m_vertical ? 1 : 0
    }
    
    fileprivate override func updateNodeTexture() -> Void {
        if isSingle {
            m_nodes[0].texture = getSinglePillTexture(color: m_colors.0)
            m_nodes[1].isHidden = true
        }
        else {
            m_nodes[0].texture = getDoublePillTexture(color: m_colors.0, vertical: m_vertical, firstPart: true)
            m_nodes[1].texture = getDoublePillTexture(color: m_colors.1, vertical: m_vertical, firstPart: false)
        }
    }
}

// MARK: BASE PILL

fileprivate class BasePill : SKNode {
    fileprivate var m_vertical: Bool
    fileprivate var m_colors: ColorPair
    fileprivate var m_settling: Bool = false
    fileprivate var m_nodes: [SKSpriteNode]
    
    // MARK: Initializers
    
    fileprivate enum InitMethod {
        case coder(NSCoder)
        case regular(Int)
    }
    
    convenience init?(color1: Color, color2: Color, vertical: Bool) {
        self.init(color1, color2, vertical, .regular(0))
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let params = getSharedDecoding(aDecoder)
        self.init(params.c1, params.c2, params.v, .coder(aDecoder))
    }
    
    fileprivate init?(_ color1: Color, _ color2: Color, _ vertical: Bool, _ initMethod: InitMethod) {
        m_colors = (color1, color2)
        m_vertical = vertical
        
        let n1 = SKSpriteNode(texture: nil, size: CGSize(width: 1, height: 1))
        n1.anchorPoint = CGPoint(x: 0, y: 1)
        let n2 = SKSpriteNode(texture: nil, size: CGSize(width: 1, height: 1))
        n2.anchorPoint = CGPoint(x: 0, y: 1)
        m_nodes = [n1, n2]
        
        switch initMethod {
        case .coder(let nSCoder):
            super.init(coder: nSCoder)
        case .regular(_):
            super.init()
        }
        
        self.addChild(n1)
        self.addChild(n2)
        
        updateNodeTexture()
        updateNodePosition()
    }
    
    // MARK: Getters / Setters
    
    public var isVertical: Bool {get {return m_vertical}}
    public var colors: ColorPair {get {return (m_colors.0, m_colors.1)}}
    public var isSingle: Bool {get {return m_colors.0 != .None && m_colors.1 == .None}}
    
    // MARK: Rotations
    
    public func rotateClockwise() {
        // can't rotate if singular
        guard !isSingle else {
            return
        }
        
        // swap when going from vertical to horizontal
        if m_vertical {
            let c = m_colors.0
            m_colors.0 = m_colors.1
            m_colors.1 = c
        }
        
        m_vertical = !m_vertical
        
        updateNodeTexture()
        updateNodePosition()
    }
    
    public func rotateCounterClockwise() {
        // can't rotate if singular
        guard !isSingle else {
            return
        }
        
        m_vertical = !m_vertical
        
        // swap when going from horizontal to vertical
        if m_vertical {
            let c = m_colors.0
            m_colors.0 = m_colors.1
            m_colors.1 = c
        }
        
        updateNodeTexture()
        updateNodePosition()
    }
    
    // MARK: Private Methods
    
    fileprivate func updateNodePosition() {}
    fileprivate func updateNodeTexture() {}
}

// MARK: Factory Methods

fileprivate func pickRandomColor() -> Color {
    let num = Int.random(in: 0..<3)
    switch num {
    case 0: return .Red
    case 1: return .Yellow
    default: return .Blue
    }
}
