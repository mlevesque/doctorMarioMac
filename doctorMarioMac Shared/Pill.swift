//
//  Pill.swift
//  doctorMarioMac
//
//  Created by Michael Levesque on 12/23/21.
//

import SpriteKit

public typealias IntPoint = (x: Int, y: Int)

public enum CellColor {
    case None
    case Red
    case Yellow
    case Blue
}

public class Pill {
    private var m_cellPosition: IntPoint
    private var m_vertical: Bool
    private var m_colors: (CellColor, CellColor)
    private var m_nodes: (SKSpriteNode?, SKSpriteNode?)
    
    init(position: IntPoint, vertical: Bool, colors: (CellColor, CellColor)) {
        m_cellPosition = position
        m_vertical = vertical
        m_colors = colors
        m_nodes = (nil, nil)
    }
    
    func getCellPosition() -> IntPoint {
        return (m_cellPosition.x, m_cellPosition.y)
    }
    
    func getColors() -> (CellColor, CellColor) {
        return (m_colors.0, m_colors.1)
    }
    
    func isSinglePellet() -> Bool {
        return m_colors.1 == .None
    }
    
    func isVertical() -> Bool {
        return !isSinglePellet() && m_vertical
    }
    
    func getPillExtendedOffset() -> IntPoint {
        return isSinglePellet() ? (0, 0) : m_vertical ? (0, 1) : (1, 0)
    }
    
    func rotateRight() {
        if m_vertical {
            swapColors()
        }
        m_vertical = !m_vertical
    }
    
    func rotateLeft() {
        if !m_vertical {
            swapColors()
        }
        m_vertical = !m_vertical
    }
    
    private func swapColors() {
        // don't swap if second color is none (indicates a single cell pill)
        guard m_colors.1 != .None else {
            return
        }
        let c = m_colors.0
        m_colors.0 = m_colors.1
        m_colors.1 = c
    }
}
