//
//  Gameboard.swift
//  doctorMarioMac
//
//  Created by Michael Levesque on 12/25/21.
//

import SpriteKit

public enum Linkage {
    case None
    case Left
    case Right
    case Up
    case Down
}

public protocol ICell {
    var color: Color {get}
    var isVirus: Bool {get}
    var link: Linkage {get}
    var markedForDestruction: Bool {get}
}

public protocol IGameboard : SKNode {
    var gridWidth: Int {get}
    var gridHeight: Int {get}
    var cellWidth: CGFloat {get}
    var cellHeight: CGFloat {get}
    
    func isInBounds(x: Int, y: Int) -> Bool
    
    func clear() -> Void
    func setEmpty(x: Int, y: Int) -> Void
    func setVirus(x: Int, y: Int, color: Color) -> Void
    func setSinglePill(x: Int, y: Int, color: Color) -> Void
    func setDoublePill(startX: Int, startY: Int, vertical: Bool, color1: Color, color2: Color) -> Void
    func markForDestruction(x: Int, y: Int) -> Void
    func removeDestructionCells() -> Void
    
    func getCellInfo(x: Int, y: Int) -> ICell
    
    func Update(frameTime t: CGFloat) -> Void
}

fileprivate struct Cell : ICell {
    var color: Color = .None
    var isVirus: Bool = false
    var markedForDestruction: Bool = false
    var link: Linkage = .None
    var node: SKSpriteNode?
}

fileprivate class Gameboard : SKNode, IGameboard {
    private let m_gridWidth: Int
    private let m_gridHeight: Int
    private let m_cellWidth: CGFloat
    private let m_cellHeight: CGFloat
    private var m_cells: [[Cell]]
    
    private var m_virusTextures: Dictionary<Color, [SKTexture]>
    private var m_virusFrame: Int = 0
    private let m_virusInterval: CGFloat = 0.2
    
    private var m_timeElapsed: CGFloat = 0
    
    typealias CellEntry = (pos: IntPoint, color: Color)
    
    // MARK: Initialization
    
    enum InitMethod {
        case coder(NSCoder)
        case regular(Int)
    }
    
    convenience init?(gridWidth: Int, gridHeight: Int, cellWidth: CGFloat, cellHeight: CGFloat) {
        self.init(gridWidth, gridHeight, cellWidth, cellHeight, .regular(0))
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let gridWidth = aDecoder.decodeInteger(forKey: "gridWidth")
        let gridHeight = aDecoder.decodeInteger(forKey: "gridHeight")
        let cellWidth = CGFloat(aDecoder.decodeFloat(forKey: "cellWidth"))
        let cellHeight = CGFloat(aDecoder.decodeFloat(forKey: "cellHeight"))
        self.init(gridWidth, gridHeight, cellWidth, cellHeight, .coder(aDecoder))
    }
    
    private init?(_ gridWidth: Int, _ gridHeight: Int, _ cellWidth: CGFloat, _ cellHeight: CGFloat, _ initMethod: InitMethod) {
        m_gridWidth = gridWidth
        m_gridHeight = gridHeight
        m_cellWidth = cellWidth
        m_cellHeight = cellHeight
        m_cells = Array.init(repeating: Array.init(repeating: Cell(), count: m_gridWidth), count: m_gridHeight)
        
        // Build virus textures
        m_virusTextures = Dictionary()
        m_virusTextures[.Red] = [getTexture("tile_virus_red_1"), getTexture("tile_virus_red_2")]
        m_virusTextures[.Blue] = [getTexture("tile_virus_blue_1"), getTexture("tile_virus_blue_2")]
        m_virusTextures[.Yellow] = [getTexture("tile_virus_yellow_1"), getTexture("tile_virus_yellow_2")]
        
        switch initMethod {
        case .coder(let nSCoder):
            super.init(coder: nSCoder)
        case .regular(_):
            super.init()
        }
        
        // attach all nodes to gameboard node
        actOnAllCells({(x: Int, y: Int, _ cell: inout Cell) -> Void in
            cell.node = SKSpriteNode(texture: nil, size: CGSize(width: m_cellWidth, height: m_cellHeight))
            cell.node!.isHidden = true
            cell.node!.position = CGPoint(x: CGFloat(x) * m_cellWidth, y: -CGFloat(y) * m_cellHeight)
            self.addChild(cell.node!)
        })
    }
    
    // MARK: Private methods
    private func actOnCell(x: Int, y: Int, _ block: (_ x: Int, _ y: Int, _ cell: inout Cell) -> Void) {
        block(x, y, &m_cells[y][x])
    }
    
    private func actOnAllCells(_ block: (_ x: Int, _ y: Int, _ cell: inout Cell) -> Void) {
        for y in 0..<m_gridHeight {
            for x in 0..<m_gridWidth {
                actOnCell(x: x, y: y, block)
            }
        }
    }
    
    private func unlinkAdjacents(x: Int, y: Int) {
        actOnCell(x: x - 1, y: y, {(x: Int, y: Int, _ cell: inout Cell) -> Void in
            if cell.link == .Right {
                cell.link = .None
            }
        })
        actOnCell(x: x + 1, y: y, {(x: Int, y: Int, _ cell: inout Cell) -> Void in
            if cell.link == .Left {
                cell.link = .None
            }
        })
        actOnCell(x: x, y: y - 1, {(x: Int, y: Int, _ cell: inout Cell) -> Void in
            if cell.link == .Down {
                cell.link = .None
            }
        })
        actOnCell(x: x, y: y + 1, {(x: Int, y: Int, _ cell: inout Cell) -> Void in
            if cell.link == .Up {
                cell.link = .None
            }
        })
    }
    
    // MARK: Getters
    var gridWidth: Int {get {return m_gridWidth}}
    var gridHeight: Int {get {return m_gridHeight}}
    var cellWidth: CGFloat {get {return m_cellWidth}}
    var cellHeight: CGFloat {get {return m_cellHeight}}
    
    func isInBounds(x: Int, y: Int) -> Bool {
        return x >= 0 && y >= 0 && x < m_gridWidth && y < m_gridHeight
    }
    
    // MARK: Setting Cells
    func clear() -> Void {
        actOnAllCells({(x: Int, y: Int, _ cell: inout Cell) -> Void in
            cell.color = .None
            cell.isVirus = false
            cell.markedForDestruction = false
            cell.link = .None
            cell.node!.isHidden = true
            cell.node!.texture = getTexture("")
        })
    }
    
    func setEmpty(x: Int, y: Int) -> Void {
        actOnCell(x: x, y: y, {(x: Int, y: Int, _ cell: inout Cell) -> Void in
            cell.color = .None
            cell.isVirus = false
            cell.markedForDestruction = false
            cell.link = .None
            cell.node!.isHidden = true
        })
    }
    
    func setVirus(x: Int, y: Int, color: Color) -> Void {
        actOnCell(x: x, y: y, {(x: Int, y: Int, _ cell: inout Cell) -> Void in
            cell.color = color
            cell.isVirus = true
            cell.markedForDestruction = false
            cell.link = .None
            cell.node!.isHidden = false
            cell.node!.texture = self.m_virusTextures[color]?[self.m_virusFrame] ?? getTexture("")
        })
    }
    
    func setSinglePill(x: Int, y: Int, color: Color) -> Void {
        actOnCell(x: x, y: y, {(x: Int, y: Int, _ cell: inout Cell) -> Void in
            cell.color = color
            cell.isVirus = false
            cell.markedForDestruction = false
            cell.link = .None
            cell.node!.isHidden = false
            cell.node!.texture = getTexture("tile_pill_\(color.description)_s")
        })
    }
    
    func setDoublePill(startX: Int, startY: Int, vertical: Bool, color1: Color, color2: Color) -> Void {
        actOnCell(x: startX, y: startY, {(x: Int, y: Int, _ cell: inout Cell) -> Void in
            cell.color = color1
            cell.isVirus = false
            cell.markedForDestruction = false
            cell.link = vertical ? .Down : .Right
            cell.node!.isHidden = false
            cell.node!.texture = getTexture("tile_pill_\(color1.description)_\(vertical ? "v" : "h")1")
        })
        let nextX = vertical ? startX : startX + 1
        let nextY = vertical ? startY + 1 : startY
        actOnCell(x: nextX, y: nextY, {(x: Int, y: Int, _ cell: inout Cell) -> Void in
            cell.color = color2
            cell.isVirus = false
            cell.markedForDestruction = false
            cell.link = vertical ? .Up : .Left
            cell.node!.isHidden = false
            cell.node!.texture = getTexture("tile_pill_\(color2.description)_\(vertical ? "v" : "h")2")
        })
    }
    
    func markForDestruction(x: Int, y: Int) -> Void {
        unlinkAdjacents(x: x, y: y)
        actOnCell(x: x, y: y, {(x: Int, y: Int, _ cell: inout Cell) -> Void in
            if cell.color != .None {
                cell.markedForDestruction = true
                cell.link = .None
                cell.node!.isHidden = false
                cell.node!.texture = getTexture("tile_destruct")
            }
        })
    }
    
    func removeDestructionCells() -> Void {
        actOnAllCells({(x: Int, y: Int, _ cell: inout Cell) -> Void in
            if cell.markedForDestruction {
                cell.color = .None
                cell.isVirus = false
                cell.markedForDestruction = false
                cell.link = .None
                cell.node!.isHidden = true
                cell.node!.texture = getTexture("")
            }
        })
    }
    
    func getCellInfo(x: Int, y: Int) -> ICell {
        return m_cells[y][x]
    }
    
    func Update(frameTime t: CGFloat) -> Void {
        m_timeElapsed += t
        if m_timeElapsed > m_virusInterval {
            m_timeElapsed = m_timeElapsed.truncatingRemainder(dividingBy: m_virusInterval)
            m_virusFrame = (m_virusFrame + 1) % 2
            actOnAllCells({(x: Int, y: Int, _ cell: inout Cell) -> Void in
                if cell.isVirus && !cell.markedForDestruction {
                    cell.node!.texture = m_virusTextures[cell.color]?[m_virusFrame] ?? getTexture("")
                }
            })
        }
    }
    
    
    
    /*
    private func getCell(x: Int, y: Int) -> GameboardCell? {
        guard x >= 0 && y >= 0 && x < m_gridWidth && y < m_gridHeight else {
            return nil
        }
        return m_cells[y][x]
    }
    
    private func clearCell(x: Int, y: Int) {
        if let cell = getCell(x: x, y: y) {
            cell.color = .None
            cell.link = []
            cell.isVirus = false
            cell.markedAsDestroyed = false
            if let n = cell.node {
                n.removeAllActions()
                n.removeFromParent()
            }
            cell.node?.removeAllActions()
            cell.node?.removeFromParent()
            cell.node = nil
            unlinkAdjacentCells(x: x, y: y)
        }
    }
    
    private func unlinkAdjacentCells(x: Int, y: Int) {
        if let c = getCell(x: x - 1, y: y) {
            c.link.remove(.Right)
        }
        if let c = getCell(x: x + 1, y: y) {
            c.link.remove(.Left)
        }
        if let c = getCell(x: x, y: y - 1) {
            c.link.remove(.Down)
        }
        if let c = getCell(x: x, y: y + 1) {
            c.link.remove(.Up)
        }
    }
    
    func isOccupied(x: Int, y: Int) -> Bool {
        guard let cell = getCell(x: x, y: y) else {
            return true
        }
        return cell.color != .None
    }
    
    func isVirus(x: Int, y: Int) -> (Bool, CellColor) {
        guard let cell = getCell(x: x, y: y) else {
            return (false, .None)
        }
        return (cell.isVirus, cell.color)
    }
    
    func clearAll() {
        for y in 0..<m_gridHeight {
            for x in 0..<m_gridWidth {
                clearCell(x: x, y: y)
            }
        }
    }
    
    func setVirus(x: Int, y: Int, color: CellColor) -> Bool {
        clearCell(x: x, y: y)
        guard let cell = getCell(x: x, y: y) else {
            return false
        }
        cell.isVirus = true
        cell.color = color
        let atlas = SKTextureAtlas(named: "SpriteSheet")
        
        var tex: SKTexture
        var _: SKAction
        switch color {
        case .Red:
            tex = atlas.textureNamed("tile_virus_red_1")
            //action = m_redVirusAnimation
        case .Yellow:
            tex = atlas.textureNamed("tile_virus_yellow_1")
            //action = m_yellowVirusAnimation
        case .Blue:
            tex = atlas.textureNamed("tile_virus_blue_1")
            //action = m_blueVirusAnimation
        default:
            tex = atlas.textureNamed("tile_virus_red_1")
            //action = m_redVirusAnimation
            break
        }
        tex.filteringMode = .nearest
        let sprite = SKSpriteNode(texture: tex, size: CGSize(width: CGFloat(m_cellWidth), height: CGFloat(m_cellHeight)))
        //sprite.run(action)
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
        if let cell = cell2 {
            insertPositions.append(pos2)
            clearCell(x: pos2.x, y: pos2.y)
            cell.color = col.1
            cell.link.insert(pill.isVertical() ? .Up : .Left)
        }
        if let cell = cell1 {
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
            while !visited.isVisited(x: startPos.x, y: startPos.y),
                    let cell = self.getCell(x: startPos.x, y: startPos.y),
                    cell.color == color {
                visited.setVisited(x: startPos.x, y: startPos.y)
                span += 1
                startPos.x -= dir.x
                startPos.y -= dir.y
            }
            guard span == 0 else {
                return nil
            }
            var p = (x: pos.x + dir.x, y: pos.y + dir.y)
            while !visited.isVisited(x: p.x, y: p.y),
                  let cell = self.getCell(x: p.x, y: p.y),
                  cell.color == color {
                visited.setVisited(x: p.x, y: p.y)
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
        let verticalVisited = GameboardVisitTable(width: m_gridWidth, height: m_gridHeight)
        let horizontalVisited = GameboardVisitTable(width: m_gridWidth, height: m_gridHeight)
        for pos in positions {
            if let cell = getCell(x: pos.x, y: pos.y) {
                if let match = findSpan(cell.color, pos, false, horizontalVisited) {
                    matches.append(match)
                }
                if let match = findSpan(cell.color, pos, true, verticalVisited) {
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
     */
}

public func createGameboard(gridWidth: Int, gridHeight: Int, cellWidth: CGFloat, cellHeight: CGFloat) -> IGameboard {
    return Gameboard(gridWidth: gridWidth, gridHeight: gridHeight, cellWidth: cellWidth, cellHeight: cellHeight)!
}

