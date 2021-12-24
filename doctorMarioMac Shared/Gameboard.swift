//
//  Gameboard.swift
//  doctorMarioMac
//
//  Created by Michael Levesque on 12/23/21.
//

import SpriteKit

public typealias Match = (startPos: IntPoint, isVertical: Bool, span: Int)
public typealias DestroyCompleteClosure = (_ pills: [Pill]) -> Void

fileprivate struct Linkage : OptionSet {
    var rawValue: Int
    
    static let Left = Linkage(rawValue: 1 << 0)
    static let Right = Linkage(rawValue: 1 << 1)
    static let Up = Linkage(rawValue: 1 << 2)
    static let Down = Linkage(rawValue: 1 << 3)
}

fileprivate struct GameboardCell {
    var link: Linkage
    var color: CellColor
    var isVirus: Bool
    var markedAsDestroyed: Bool
    var node: SKNode?
}

fileprivate class GameboardVisitTable {
    private typealias VisitCell = (h: Bool, v: Bool)
    private var m_grid: [[VisitCell]]
    private let m_width: Int
    private let m_height: Int
    
    init(width: Int, height: Int) {
        m_width = width
        m_height = height
        m_grid = Array.init(repeating: Array.init(repeating: (h: false, v: false), count: width), count: height)
    }
    
    private func isInBounds(x: Int, y: Int) -> Bool {
        return x >= 0 && y >= 0 && x < m_width && y < m_height
    }
    
    func isVisited(x: Int, y: Int, vertical: Bool) -> Bool {
        guard isInBounds(x: x, y: y) else {
            return true
        }
        let entry = m_grid[y][x]
        return (vertical && entry.v) || (!vertical && entry.h)
    }
    
    func setVisited(x: Int, y: Int, vertical: Bool) {
        guard isInBounds(x: x, y: y) else {
            return
        }
        var entry = m_grid[y][x]
        if vertical {
            entry.v = true
        }
        else {
            entry.h = true
        }
    }
}

public class Gameboard : SKNode {
    private var m_gridWidth: Int
    private var m_gridHeight: Int
    private var m_cellWidth: Float
    private var m_cellHeight: Float
    private var m_cells: [[GameboardCell]]
    
    typealias CellEntry = (pos: IntPoint, color: CellColor)
    
    init(gridWidth: Int, gridHeight: Int, cellWidth: Float, cellHeight: Float) {
        m_gridWidth = gridWidth
        m_gridHeight = gridHeight
        m_cellWidth = cellWidth
        m_cellHeight = cellHeight
        m_cells = Array(repeating: Array(
            repeating: GameboardCell(link: [], color: .None, isVirus: false, markedAsDestroyed: false),
            count: m_gridWidth), count: m_gridHeight)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        m_gridWidth = aDecoder.decodeInteger(forKey: "gridWidth")
        m_gridHeight = aDecoder.decodeInteger(forKey: "gridHeight")
        m_cellWidth = aDecoder.decodeFloat(forKey: "cellWidth")
        m_cellHeight = aDecoder.decodeFloat(forKey: "cellHeight")
        m_cells = Array(repeating: Array(
            repeating: GameboardCell(link: [], color: .None, isVirus: false, markedAsDestroyed: false),
            count: m_gridWidth), count: m_gridHeight)
        super.init(coder: aDecoder)
    }
    
    private func getCell(x: Int, y: Int) -> GameboardCell? {
        guard x >= 0 && y >= 0 && x < m_gridWidth && y < m_gridHeight else {
            return nil
        }
        return m_cells[y][x]
    }
    
    private func clearCell(x: Int, y: Int) {
        if var cell = getCell(x: x, y: y) {
            cell.color = .None
            cell.link = []
            cell.isVirus = false
            cell.markedAsDestroyed = false
            if let n = cell.node {
                n.removeAllActions()
                n.removeFromParent()
            }
            cell.node = nil
            unlinkAdjacentCells(x: x, y: y)
        }
    }
    
    private func unlinkAdjacentCells(x: Int, y: Int) {
        if var c = getCell(x: x - 1, y: y) {
            c.link.remove(.Right)
        }
        if var c = getCell(x: x + 1, y: y) {
            c.link.remove(.Left)
        }
        if var c = getCell(x: x, y: y - 1) {
            c.link.remove(.Down)
        }
        if var c = getCell(x: x, y: y + 1) {
            c.link.remove(.Up)
        }
    }
    
    func clearAll() {
        for y in 0..<m_gridHeight {
            for x in 0..<m_gridWidth {
                clearCell(x: x, y: y)
            }
        }
    }
    
    func setVirus(x: Int, y: Int, color: CellColor) -> Bool {
        guard var cell = getCell(x: x, y: y) else {
            return false
        }
        clearCell(x: x, y: y)
        cell.isVirus = true
        cell.color = color
        let atlas = SKTextureAtlas(named: "SpriteSheet")
        let tex = atlas.textureNamed("tile_virus_red_1")
        tex.filteringMode = .nearest
        let sprite = SKSpriteNode(texture: tex, size: CGSize(width: CGFloat(m_cellWidth), height: CGFloat(m_cellHeight)))
        sprite.position = CGPoint(x: CGFloat(Float(x) * m_cellWidth), y: -CGFloat(Float(y) * m_cellHeight))
        cell.node = sprite
        self.addChild(cell.node!)
        return true
    }
    
    func unsetVirus(x: Int, y: Int) -> Bool {
        guard let cell = getCell(x: x, y: y), cell.isVirus else {
            return false
        }
        clearCell(x: x, y: y)
        return true
    }
    
    func isCollisionCell(x: Int, y: Int) -> Bool {
        if let cell = getCell(x: x, y: y), cell.color == .None {
            return false
        }
        return true
    }
    
    func willPillCollide(pill: Pill, x: Int, y: Int) -> Bool {
        if !pill.isSinglePellet() {
            let offset = pill.getPillExtendedOffset()
            if isCollisionCell(x: x + offset.x, y: y + offset.y) {
                return true
            }
        }
        if isCollisionCell(x: x, y: y) {
            return true
        }
        return false
    }
    
    func isPillRestingAboveCollision(pill: Pill) -> Bool {
        let pos = pill.getCellPosition()
        let off = pill.getPillExtendedOffset()
        if !pill.isVertical() {
            if isCollisionCell(x: pos.x, y: pos.y + 1) {
                return true
            }
        }
        return isCollisionCell(x: pos.x + off.x, y: pos.y + off.y + 1)
    }
    
    func insertPillAndReturnInsertPositions(pill: Pill) -> [IntPoint] {
        let pos1 = pill.getCellPosition()
        let off = pill.getPillExtendedOffset()
        let pos2: IntPoint = (pos1.x + off.x, pos1.y + off.y)
        let col = pill.getColors()
        let cell1 = getCell(x: pos1.x, y: pos1.y)
        let cell2 = pill.isSinglePellet() ? nil : getCell(x: pos2.x, y: pos2.y)
        var insertPositions: [IntPoint] = []
        if cell1 != nil {
            insertPositions.append(pos1)
            clearCell(x: pos1.x, y: pos1.y)
        }
        if var cell = cell2 {
            insertPositions.append(pos2)
            clearCell(x: pos2.x, y: pos2.y)
            cell.color = col.1
            cell.link.insert(pill.isVertical() ? .Up : .Left)
        }
        if var cell = cell1 {
            cell.color = col.0
            if !pill.isSinglePellet() {
                cell.link.insert(pill.isVertical() ? .Down : .Right)
            }
        }
        return insertPositions
    }
    
    func findMatchesFromPositions(positions: [IntPoint]) -> [Match] {
        let findSpan = { (color: CellColor, pos: IntPoint, vertical: Bool, visited: GameboardVisitTable) -> Match? in
            let dir = vertical ? (x: 0, y: 1) : (x: 1, y: 0)
            var startPos = (x: pos.x, y: pos.y)
            var span = 0
            while !visited.isVisited(x: startPos.x, y: startPos.y, vertical: vertical),
                    let cell = self.getCell(x: startPos.x, y: startPos.y),
                    cell.color == color {
                visited.setVisited(x: startPos.x, y: startPos.y, vertical: vertical)
                span += 1
                startPos.x -= dir.x
                startPos.y -= dir.y
            }
            guard span == 0 else {
                return nil
            }
            var p = (x: pos.x + dir.x, y: pos.y + dir.y)
            while !visited.isVisited(x: p.x, y: p.y, vertical: vertical),
                  let cell = self.getCell(x: p.x, y: p.y),
                  cell.color == color {
                visited.setVisited(x: p.x, y: p.y, vertical: vertical)
                span += 1
                p.x += dir.x
                p.y += dir.y
            }
            if span < 3 {
                return nil
            }
            return (startPos: startPos, isVertical: vertical, span: span)
        }
        
        var matches: [Match] = []
        let visited = GameboardVisitTable(width: m_gridWidth, height: m_gridHeight)
        for pos in positions {
            if let cell = getCell(x: pos.x, y: pos.y) {
                if let match = findSpan(cell.color, pos, false, visited) {
                    matches.append(match)
                }
                if let match = findSpan(cell.color, pos, true, visited) {
                    matches.append(match)
                }
            }
        }
        return matches
    }
    
    func extractPill(x: Int, y: Int) -> Pill? {
        guard let cell = getCell(x: x, y: y), !cell.isVirus else {
            return nil
        }
        var entry1: CellEntry = (pos: (x: x, y: y), color: cell.color)
        var entry2: CellEntry = (pos: (x: x, y: y), color: .None)
        var vertical = false
        if cell.link.contains(.Left) {
            entry2 = entry1
            let pos = (x: x - 1, y: y)
            entry1 = (pos: pos, color: getCell(x: pos.x, y: pos.y)?.color ?? .None)
        }
        else if cell.link.contains(.Up) {
            vertical = true
            entry2 = entry1
            let pos = (x: x, y: y - 1)
            entry1 = (pos: pos, color: getCell(x: pos.x, y: pos.y)?.color ?? .None)
        }
        else if cell.link.contains(.Right) {
            let pos = (x: x + 1, y: y)
            entry2 = (pos: pos, color: getCell(x: pos.x, y: pos.y)?.color ?? .None)
        }
        else if cell.link.contains(.Down) {
            vertical = true
            let pos = (x: x, y: y + 1)
            entry2 = (pos: pos, color: getCell(x: pos.x, y: pos.y)?.color ?? .None)
        }
        
        clearCell(x: entry1.pos.x, y: entry1.pos.y)
        clearCell(x: entry2.pos.x, y: entry2.pos.y)
        
        return Pill(position: entry1.pos, vertical: vertical, colors: (entry1.color, entry2.color))
    }
}
